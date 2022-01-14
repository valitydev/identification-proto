/*
 * Базовые, наиболее общие определения
 * Заимствовано из damsel/proto/base.thrift
 * commit id: b0806eb1d55646cbb937206ad8183e6d3f62719a
 */

namespace java dev.vality.identity.base
namespace erlang identity_base

/** Идентификатор */
typedef string ID

/** Непрозрачный для участника общения набор данных */
typedef binary Opaque

/**
 * Отметка во времени согласно RFC 3339.
 *
 * Строка должна содержать дату и время в UTC в следующем формате:
 * `2016-03-22T06:12:27Z`.
 */
typedef string Timestamp

/* Может пригодиться */
/* ToDo @arentrue: удалить перед мержем в мастер! */

/** Пространство имён */
/* typedef string Namespace */

/** Идентификатор некоторого события */
/* typedef i64 EventID */

/** Набор данных, подлежащий интерпретации согласно типу содержимого. */

/*
struct Content {
    /** Тип содержимого, согласно [RFC2046](https://www.ietf.org/rfc/rfc2046)
    1: required string type
    2: required binary data
}
*/

/* typedef i32 Timeout */

/** Значение ассоциации */
/* typedef string Tag */
