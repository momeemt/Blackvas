/* Generated by the Nim Compiler v1.0.6 */
/*   (c) 2019 Andreas Rumpf */

var framePtr = null;
var excHandler = 0;
var lastJSError = null;
if (typeof Int8Array === 'undefined') Int8Array = Array;
if (typeof Int16Array === 'undefined') Int16Array = Array;
if (typeof Int32Array === 'undefined') Int32Array = Array;
if (typeof Uint8Array === 'undefined') Uint8Array = Array;
if (typeof Uint16Array === 'undefined') Uint16Array = Array;
if (typeof Uint32Array === 'undefined') Uint32Array = Array;
if (typeof Float32Array === 'undefined') Float32Array = Array;
if (typeof Float64Array === 'undefined') Float64Array = Array;
var nim_program_result = 0;
var global_raise_hook_18618 = [null];
var local_raise_hook_18623 = [null];
var out_of_mem_hook_18626 = [null];
  if (!Math.trunc) {
    Math.trunc = function(v) {
      v = +v;
      if (!isFinite(v)) return v;

      return (v - v % 1)   ||   (v < 0 ? -0 : v === 0 ? v : 0);
    };
  }

function canvas(id_46039) {
	var result_46040 = 0;

	var F={procname:"HighCanvas.canvas",prev:framePtr,filename:"HighCanvas.nim",line:0};
	framePtr = F;
		F.line = 16;
		document.getElementById(id_46039);
		F.line = 17;
		result_46040 = 0;
	framePtr = F.prev;

	return result_46040;

}
