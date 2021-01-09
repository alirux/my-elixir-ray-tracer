defmodule MyElixirRayTracer.Transformations do

  import MyElixirRayTracer.Matrix

  @doc """
  Translation transformation applies a *(x, y, z) translation* to the t transformation

  This transformation adds (dx, dy, dz) offsets to coordinates
  """
  def translation(t, dx, dy, dz) do
    trans_t = matrix4x4(1, 0, 0, dx,
                        0, 1, 0, dy,
                        0, 0, 1, dz,
                        0, 0, 0,  1)
    { :ok, translated_t } = matrix_multiply(trans_t, t)
    translated_t
  end

  @doc """
  Scaling transformation applies a *(dx, dy, dz) scale* to the t transformation

  This transformation multiplies the coordinates with (dx, dy, dz)
  """
  def scaling(t, dx, dy, dz) do
    scale_t = matrix4x4(dx, 0,  0,  0,
                        0,  dy, 0,  0,
                        0,  0,  dz, 0,
                        0,  0,  0,  1)
    { :ok, scaled_t } = matrix_multiply(scale_t, t)
    scaled_t
  end

  @doc """
  Rotation on the x axis by rad_degree radiant
  """
  def rotation_x(t, rad_degree) do
    cos = :math.cos(rad_degree)
    sin = :math.sin(rad_degree)
    x_rot_t = matrix4x4(1,    0,    0, 0,
                        0,  cos, -sin, 0,
                        0,  sin,  cos, 0,
                        0,    0,    0, 1)
    { :ok, x_rotated_t } = matrix_multiply(x_rot_t, t)
    x_rotated_t
  end

  @doc """
  Rotation on the y axis by rad_degree radiant
  """
  def rotation_y(t, rad_degree) do
    cos = :math.cos(rad_degree)
    sin = :math.sin(rad_degree)
    y_rot_t = matrix4x4(cos,  0,  sin, 0,
                        0,    1,    0, 0,
                        -sin, 0,  cos, 0,
                        0,    0,    0, 1)
    { :ok, y_rotated_t } = matrix_multiply(y_rot_t, t)
    y_rotated_t
  end

  @doc """
  Rotation on the z axis by rad_degree radiant
  """
  def rotation_z(t, rad_degree) do
    cos = :math.cos(rad_degree)
    sin = :math.sin(rad_degree)
    z_rot_t = matrix4x4(cos, -sin, 0, 0,
                        sin,  cos, 0, 0,
                          0,    0, 1, 0,
                          0,    0, 0, 1)
    { :ok, z_rotated_t } = matrix_multiply(z_rot_t, t)
    z_rotated_t
  end

  @doc """
  Shearing transformation
  """
  def shearing(t, xy, xz, yx, yz, zx, zy) do
    shearing_t = matrix4x4( 1, xy, xz, 0,
                           yx,  1, yz, 0,
                           zx, zy,  1, 0,
                            0,  0,  0, 1)
    { :ok, sheared_t } = matrix_multiply(shearing_t, t)
    sheared_t
  end

  def set_transform(object, trans_matrix) do
    %{ object | transform: trans_matrix }
  end

end
