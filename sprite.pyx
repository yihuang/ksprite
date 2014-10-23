from kivy.graphics.transformation import Matrix
from libc.math cimport sin, cos

# PI / 180
cdef float DEGREES_TO_RADIANS(float __ANGLE__):
    return __ANGLE__ * 0.01745329252
# PI * 180
cdef float RADIANS_TO_DEGREES(float __ANGLE__):
    return __ANGLE__ * 57.29577951

cdef class Node2(object):
    cdef list children

    cdef object _transform
    cdef bint _transform_dirty

    # affine transform
    cdef float _position_x
    cdef float _position_y

    cdef float _anchor_x
    cdef float _anchor_y

    cdef float _scale_x
    cdef float _scale_y

    cdef float _rotation_x
    cdef float _rotation_y

    cdef float _skew_x
    cdef float _skew_y

    # color
    cdef unsigned char _color_r
    cdef unsigned char _color_g
    cdef unsigned char _color_b
    cdef unsigned char _color_a

    property x:
        def __set__(self, x):
            self._transform_dirty = True
            self._position_x = x
        def __get__(self):
            return self._position_x

    property y:
        def __set__(self, y):
            self._transform_dirty = True
            self._position_y = y
        def __get__(self):
            return self._position_y

    property position:
        def __set__(self, t):
            self._transform_dirty = True
            self._position_x = t[0]
            self._position_y = t[1]
        def __get__(self):
            return (self._position_x, self._position_y)

    property anchor_x:
        def __set__(self, x):
            self._transform_dirty = True
            self._anchor_x = x
        def __get__(self):
            return self._anchor_x

    property anchor_y:
        def __set__(self, y):
            self._transform_dirty = True
            self._anchor_y = y
        def __get__(self):
            return self._anchor_y

    property anchor:
        def __set__(self, t):
            self._transform_dirty = True
            self._anchor_x = t[0]
            self._anchor_y = t[0]
        def __get__(self):
            return (self._anchor_x, self._anchor_y)

    property scale_x:
        def __set__(self, x):
            self._transform_dirty = True
            self._scale_x = x
        def __get__(self):
            return self._scale_x

    property scale_y:
        def __set__(self, y):
            self._transform_dirty = True
            self._scale_y = y
        def __get__(self):
            return self._scale_y

    property scale:
        def __set__(self, t):
            self._transform_dirty = True
            self._scale_x = t[0]
            self._scale_y = t[0]
        def __get__(self):
            return (self._scale_x, self._scale_y)

    property rotation_x:
        def __set__(self, x):
            self._transform_dirty = True
            self._rotation_x = x
        def __get__(self):
            return self._rotation_x

    property rotation_y:
        def __set__(self, y):
            self._transform_dirty = True
            self._rotation_y = y
        def __get__(self):
            return self._rotation_y

    property rotation:
        def __set__(self, t):
            self._transform_dirty = True
            self._rotation_x = t[0]
            self._rotation_y = t[0]
        def __get__(self):
            return (self._rotation_x, self._rotation_y)

    property skew_x:
        def __set__(self, x):
            self._transform_dirty = True
            self._skew_x = x
        def __get__(self):
            return self._skew_x

    property skew_y:
        def __set__(self, y):
            self._transform_dirty = True
            self._skew_y = y
        def __get__(self):
            return self._skew_y

    property skew:
        def __set__(self, t):
            self._transform_dirty = True
            self._skew_x = t[0]
            self._skew_y = t[0]
        def __get__(self):
            return (self._skew_x, self._skew_y)

    property transform:
        #@cython.cdivision(True)
        def __get__(self):
            cdef float x
            cdef float y
            cdef float cx = 1, sx = 0, cy = 1, sy = 0
            cdef float radiansX
            cdef float radiansY
            cdef bint has_skew
            cdef bint has_anchor
            if self._transform_dirty:
                # compute transform

                x = self._position_x;
                y = self._position_y;

                #if (m_bIgnoreAnchorPointForPosition) 
                #{
                #    x += m_obAnchorPointInPoints.x;
                #    y += m_obAnchorPointInPoints.y;
                #}

                # Rotation values
                # Change rotation code to handle X and Y
                # If we skew with the exact same value for both x and y then we're simply just rotating
                if self._rotation_x or self._rotation_y:
                    radiansX = -DEGREES_TO_RADIANS(self._rotation_x)
                    radiansY = -DEGREES_TO_RADIANS(self._rotation_y)
                    cx = cos(radiansX)
                    sx = sin(radiansX)
                    cy = cos(radiansY)
                    sy = sin(radiansY)

                has_skew = self._skew_x > 0 or self._skew_y > 0
                has_anchor = self._anchor_x > 0 or self._anchor_y > 0

                # optimization:
                # inline anchor point calculation if skew is not needed
                # Adjusted transform calculation for rotational skew
                if not has_skew and has_anchor:
                    x += cy * -self._anchor_x * self._scale_x + -sx * -self._anchor_y * self._scale_y
                    y += sy * -self._anchor_x * self._scale_x +  cx * -self._anchor_y * self._scale_y

                # Build Transform Matrix
                # Adjusted transform calculation for rotational skew
                self._transform = Matrix( cy * self._scale_x,  sy * self._scale_x,
                    -sx * self._scale_y, cx * self._scale_y,
                    x, y )

                ## XXX: Try to inline skew
                ## If skew is needed, apply skew and then anchor point
                #if has_skew:
                #    CCAffineTransform skewMatrix = CCAffineTransformMake(1.0f, tanf(DEGREES_TO_RADIANS(m_fSkewY)),
                #        tanf(DEGREES_TO_RADIANS(m_fSkewX)), 1.0f,
                #        0.0f, 0.0f );
                #    m_sTransform = CCAffineTransformConcat(skewMatrix, m_sTransform);

                #    # adjust anchor point
                #    if has_anchor:
                #        self._transform = CCAffineTransformTranslate(m_sTransform, -m_obAnchorPointInPoints.x, -m_obAnchorPointInPoints.y);

                self._transform_dirty = False
            return self._transform

    property rgba:
        def __set__(self, t):
            self._color_r = t[0]
            self._color_g = t[1]
            self._color_b = t[2]
            self._color_a = t[3]
        def __get__(self):
            return (self._color_r, self._color_g, self._color_b, self._color_a)

    property rgb:
        def __set__(self, t):
            self._color_r = t[0]
            self._color_g = t[1]
            self._color_b = t[2]
        def __get__(self):
            return (self._color_r, self._color_g, self._color_b)

    property alpha:
        def __set__(self, int a):
            self._color_a = a
        def __get__(self):
            return self._color_a

    cdef fill_buffer(self, char* p):
        pass
