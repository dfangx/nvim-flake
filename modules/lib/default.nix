lib: lib.extend(final: prev: {
  nvim = {
    lua = import ./lua.nix { lib = final; };
  };

  # For forward compatibility.
  literalExpression = prev.literalExpression or prev.literalExample;
  literalDocBook = prev.literalDocBook or prev.literalExample;
})
