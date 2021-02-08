/**
 * Сервис идентификации, хранения статуса идентификации
 * и привязки идентифицированной сущности к ее владельцу.
 */

namespace java com.rbkmoney.identity
namespace erlang identity

include "base.thrift"
include "context.thrift"

typedef base.ID                 IdentityID
typedef base.ID                 EntityID
typedef base.ID                 IdentityClaimID
typedef base.Opaque             IdentityDocumentToken

typedef list<IdentityDocument>  IdentityDocuments

struct Identity {
    1: required IdentityID          id
    2: optional EntityID            owner_id   // владелец идентификации
    3: optional IdentificationLevel level
}

enum IdentificationLevel {
    none    = 100
    partial = 200
    full    = 300
}

/**
 * Заявка на изменение статуса идентификации.
 */
struct IdentityClaim {
    1: required IdentityClaimID        id
    2: required IdentityID             identity_id
    3: required EntityID               claimant
    4: required IdentificationLevel    target_level
    5: required IdentityDocuments      proof
    6: required IdentityClaimStatus    status

    99: optional context.ContextSet    context  // непрозрачный контекст заявки
}

union IdentityClaimStatus {
    1: ClaimCreated   created
    2: ClaimReview    review
    3: ClaimApproved  approved
    4: ClaimDenied    denied
    5: ClaimCancelled cancelled
    6: ClaimFailed    failed
}

/**
 * Для получения статуса полной (full) или нулевой (none) идентификации
 * заявка сразу создается в статусе review и ждет принятия решения
 * с api сервиса IdentificationJudgement.
 *
 * Для получения статуса частичной (partial) идентификации статус review проходит
 * в автоматическом режиме.
 */

struct ClaimCreated   { 1: optional string details }
struct ClaimReview    { 1: optional string details }
struct ClaimApproved  { 1: optional string details }
struct ClaimDenied    { 1: optional string details }
struct ClaimCancelled { 1: optional string details }

typedef Failure ClaimFailed

struct IdentityDocument {
    1: required IdentityDocumentType  type
    2: required IdentityDocumentToken token
}

union IdentityDocumentType {
    1: RUSDomesticPassport     rus_domestic_passport
    2: RUSRetireeInsuranceCert rus_retiree_insurance_cert
}

struct RUSDomesticPassport     {}
struct RUSRetireeInsuranceCert {}

/**
 * Структура Failure заимствована из damsel/proto/domain.thrift
 * commit id: b0806eb1d55646cbb937206ad8183e6d3f62719a
 *
 * "Динамическое" представление ошибки,
 * должно использоваться только для передачи,
 * для интерпретации нужно использовать конвертацию в типизированный вид.
 *
 * Если при попытке интерпретировать код через типизированный вид происходит ошибка (нет такого типа),
 * то это означает, что ошибка неизвестна, и такую ситуацию нужно уметь обрабатывать
 * (например просто отдать неизветсную ошибку наверх).
 *
 * Старые ошибки совместимы с новыми и будут читаться.
 * Структура осталась та же, только поле description переименовалось в reason,
 * и добавилось поле sub.
 * В результате для старых ошибок description будет в reason, а в code будет код ошибки
 * (который будет интропретирован как неизвестная ошибка).
 *
 */

struct Failure {
    1: required FailureCode   code
    2: optional FailureReason reason
    3: optional SubFailure    sub
}

typedef string FailureCode
typedef string FailureReason // причина возникшей ошибки и пояснение откуда она взялась

// возможность делать коды ошибок иерархическими
struct SubFailure {
    1: required FailureCode code
    2: optional SubFailure  sub
}

struct IdentityClaimParams {
    1: required IdentityID             identity_id
    2: required IdentificationLevel    target_level
    3: required EntityID               claimant
    4: required IdentityDocuments      proof

    99: optional context.ContextSet    context
}

exception ClaimNotFound                    {}
exception IdentityNotFound                 {}
exception InsufficientIdentityDocuments    {}
exception InvalidTargetIdentificationLevel {}
exception IdentityDocumentNotFound         { 1: required IdentityDocumentToken token }

exception ClaimPending              { 1: required IdentityClaimID id }
exception IdentityOwnershipConflict { 1: required EntityID id }
exception InvalidClaimStatus        { 1: required IdentityClaimStatus status }

service Identification {

    Identity Get (1: IdentityID id)
        throws (1: IdentityNotFound ex1)

    IdentityID GetIdentityID (1: IdentityDocuments proof)
        throws (
            1: IdentityDocumentNotFound      ex1
            2: InsufficientIdentityDocuments ex2
    )

    IdentityClaim CreateClaim (1: IdentityClaimParams params)
        throws (
            1: InsufficientIdentityDocuments    ex1
            2: ClaimPending                     ex2
            3: IdentityOwnershipConflict        ex3
            4: InvalidTargetIdentificationLevel ex4
    )

    IdentityClaim GetClaim (1: IdentityClaimID id)
        throws (1: ClaimNotFound ex1)

    IdentityClaim CancelClaim (1: IdentityClaimID id)
        throws (1: ClaimNotFound ex1, 2: InvalidClaimStatus ex2)
}

/*
 * exception OwnerNotSet {}
 */

service IdentificationJudgement {

    IdentityClaim Approve (1: IdentityClaimID id)
        throws (
            1: ClaimNotFound ex1,
            2: InvalidClaimStatus ex2
    )

    IdentityClaim Deny (1: IdentityClaimID id)
        throws (
            1: ClaimNotFound ex1,
            2: InvalidClaimStatus ex2
    )

/*
 *  Identity ResetIdentityOwner (1: IdentityID id)
 *      throws (1: IdentityNotFound ex1, 2: OwnerNotSet ex2)
 */

}
