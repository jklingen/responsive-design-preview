import 'dart:html';
import 'dart:convert';
import 'package:html5_dnd/html5_dnd.dart';

HtmlElement container;
HtmlElement draggedElement;
num previewCounter = 0;

void main() {
  container = querySelector('#container');
  querySelector('#refresh').onClick.listen(onRefreshClick);
  querySelector('#url').onChange.listen(onRefreshClick);
  createPreview(0, 0, 1024,768,0.5);
  createPreview(520, 0, 320, 480 ,0.8);
  createPreview(0, 420, 1920,1200,0.4);
  var urlInput = (querySelector('#url') as InputElement);
  if(urlInput.value.isEmpty) {
    urlInput.value = 'http://';
  } else {
    onRefreshClick(null);
  }

  SortableGroup sg = new SortableGroup();
  sg.installAll(querySelectorAll('.preview'));
  sg.isGrid = true;
}


void createPreview(num x, num y, num w, num h, double scale) {
  previewCounter++;


  var div = new DivElement();
  div
    ..id = 'preview' + previewCounter.toString()
    ..className = 'preview';
  div.style.zIndex = previewCounter;

  div.appendHtml('''

      <h3>&nbsp;
      <form>
        <span class="w" title="Change width" >$w</span>
        <input type="number" class="w" value="$w" tabindex="${previewCounter*3}"/>x
        <span class="h" title="Change height">$h</span>
        <input type="number" class="h" value="$h" tabindex="${previewCounter*3+1}"/>@
        <span class="scale"  title="Change zoom">${scale*100}</span>
        <input type="number" class="scale" value="${scale*100}" tabindex="${previewCounter*3+2}"/>%
        </form>
        <div class="preview-control">
          <span class="flaticon-duplicate1 clone" title="Clone this preview"></span>
          <span class="flaticon-close12 close" title="Close this preview"></span>
        </div>
      </h3>
    ''');

  div.children.add(new IFrameElement());

  container.children.add(div);

  updatePreviewSize(div);

  var spans = div.querySelectorAll("form span");
  for (HtmlElement span in spans) {
    span.onClick.listen(onDimensionLabelClick);
  }
  var inputs = div.querySelectorAll("form input");
  for (HtmlElement input in inputs) {
    input.onBlur.listen(onDimensionInputBlur);
  }
  div.querySelector(".preview-control .close").onClick.listen(onCloseButtonClick);
  div.querySelector(".preview-control .clone").onClick.listen(onCloneButtonClick);
}

void onDimensionLabelClick(Event e) {
  var target = (e.target as HtmlElement);
  var parent = target.parent;
  parent.querySelectorAll("span").style.display = 'none';
  parent.querySelectorAll("input").style.display = 'inline';
  (parent.querySelector("input." + target.className) as InputElement).select();


}

void onDimensionInputBlur(MouseEvent e) {
  var target = e.target as HtmlElement;
  target.parent.querySelector('span.${e.currentTarget.className}').text = target.value;

  if(e.relatedTarget == null || (e.relatedTarget as HtmlElement).parent != (e.target as HtmlElement).parent) {
    var parent = (e.target as HtmlElement).parent;
    parent.querySelectorAll("span").style.display = 'inline';
    parent.querySelectorAll("input").style.display = 'none';
  }
  DivElement previewDiv = findParentPreview(target);
  updatePreviewSize(previewDiv);
}

void onCloseButtonClick(Event e) {
  var target = (e.target as HtmlElement);
  findParentPreview(target).remove();
}

void onCloneButtonClick(Event e) {
  var preview = findParentPreview(e.target as HtmlElement);
  preview.parent.insertBefore(preview.clone(true),preview);
}


DivElement findParentPreview(HtmlElement element) {
  while (element.parent != null && element.className != 'preview') {
    element = element.parent;
  }
  return element;
}

void updatePreviewSize(DivElement previewDiv) {
  var w = int.parse((previewDiv.querySelector('input.w') as InputElement).value);
  var h = int.parse((previewDiv.querySelector('input.h') as InputElement).value);
  var s = int.parse((previewDiv.querySelector('input.scale') as InputElement).value)/100;
  previewDiv.style
    ..width = (w*s).toString() + 'px'
    ..height = (h*s+20).toString() + 'px';

  previewDiv.querySelector('iframe').style
    ..width = w.toString() + 'px'
    ..height = h.toString() + 'px'
    ..transform = 'scale(' + s.toString() + ')';
}


void onRefreshClick(Event e) {
  var iframes = querySelectorAll('iframe');
  for(var i=0; i<iframes.length; i++) {
    iframes[i].setAttribute('src', 'about:blank');
    iframes[i].setAttribute('src', (querySelector('#url') as InputElement).value);
  }
}
