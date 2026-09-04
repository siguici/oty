module eval

pub type Type = BuiltinType | NamedType | ListType | ArrayType | UnionType | IntersectionType

@[params]
pub struct TypeOption {
pub mut:
	nullable bool
}

pub enum BuiltinType {
	bool
	int
	float
	string
}

pub struct NamedType {
	TypeOption
	name string
}

pub struct ListType {
	TypeOption
	item_type Type
}

pub struct ArrayType {
	TypeOption
	key_type   Type
	value_type Type
}

struct GroupedType {
	TypeOption
mut:
	types []Type
}

pub struct UnionType {
	GroupedType
}

pub struct IntersectionType {
	GroupedType
}

pub fn Type.from(type string, opt TypeOption) Type {
	return if t := BuiltinType.from(type) {
		t
	} else {
		NamedType{
			name: type
			nullable: opt.nullable
		}
	}
}

pub fn (this BuiltinType) is(type BuiltinType) bool {
	return this == type
}
