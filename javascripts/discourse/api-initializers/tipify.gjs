import { htmlSafe } from "@ember/template";
import { apiInitializer } from "discourse/lib/api";
import TipifyWrapper from "../components/tipify-wrapper";
import { readInputList, traverseNodes } from "../lib/utilities";

export default apiInitializer("0.11.1", (api) => {
  let skipTags = {
    a: true,
    iframe: true,
  };

  settings.excluded_tags.split("|").forEach((tag) => {
    tag = tag.trim().toLowerCase();
    tag && (skipTags[tag] = true);
  });

  let skipClasses = {};

  settings.excluded_classes.split("|").forEach((cls) => {
    cls = cls.trim().toLowerCase();
    cls && (skipClasses[cls] = true);
  });

  const createTooltip = (helper, text, value) => {
    let span = document.createElement("span");
    span.className = "tipify";

    helper.renderGlimmer(
      span,
      <template>
        <TipifyWrapper @data={{text}} @value={{htmlSafe value}} />
      </template>
    );

    return span;
  };

  class Action {
    constructor(inputListName, method) {
      this.inputListName = inputListName;
      this.createNode = method;
      this.inputs = {};
    }
  }

  let tipify = new Action("tipified_words", createTooltip);
  let actions = [tipify];
  actions.forEach(readInputList);

  api.decorateCookedElement(
    (element, helper) => {
      if (!helper?.getModel()) {
        return;
      }

      actions.forEach((action) => {
        if (Object.keys(action.inputs).length > 0) {
          traverseNodes(helper, element, action, skipTags, skipClasses);
        }
      });
    },
    { onlyStream: true }
  );
});
