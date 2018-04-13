namespace java com.rbkmoney.damsel.identity
namespace erlang identity

include "base.thrift"

typedef base.ID     IdentityID
typedef base.ID     EntityID
typedef base.ID     IdentityClaimID
typedef base.Opaque IdentityDocumentToken

typedef list<IdentityDocumentToken> IdentityDocuments

struct Identity {
    1: required IdentityID          id
    2: optional EntityID            owner_id
    3: optional IdentificationLevel level
}

enum IdentificationLevel {
    none    = 100
    partial = 200
    full    = 300
}

struct IdentityClaimParams {
    1: required IdentificationLevel target_level
    2: required EntityID            claimant
    3: required IdentityDocuments   proof
    4: optional IdentityID          identity_id
}

struct IdentityClaim {
    1: required IdentityClaimID     id
    2: required IdentityID          identity_id
    3: required EntityID            claimant
    5: required IdentificationLevel target_level
    6: required IdentityDocuments   proof
    7: required IdentityClaimStatus status
}

union IdentityClaimStatus {
    1: ClaimCreated   created
    2: ClaimApproved  approved
    3: ClaimDenied    denied
    4: ClaimCancelled cancelled
    5: ClaimFailed    failed
}

struct ClaimCreated   { 1: optional string details }
struct ClaimApproved  { 1: optional string details }
struct ClaimDenied    { 1: optional string details }
struct ClaimCancelled { 1: optional string details }

typedef Failure ClaimFailed

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

exception ClaimNotFound                 {}
exception IdentityNotFound              {}
exception InsufficientIdentityDocuments {}

exception AnotherClaimActive        { 1: required IdentityClaimID id }
exception IdentityOwnershipConflict { 1: required EntityID id }
exception InvalidClaimStatus        { 1: required IdentityClaimStatus status }

service Identificaiton {

    Identity Get (1: IdentityID id)
        throws (1: IdentityNotFound ex1)

    IdentityClaimID CreateClaim (1: IdentityClaimParams params)
        throws (
            1: InsufficientIdentityDocuments ex1
            2: AnotherClaimActive            ex2
            3: IdentityOwnershipConflict     ex3
            4: IdentityNotFound              ex4
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
        throws (1: ClaimNotFound ex1, 2: InvalidClaimStatus ex2)

    IdentityClaim Deny (1: IdentityClaimID id)
        throws (1: ClaimNotFound ex1, 2: InvalidClaimStatus ex2)

/*
 *  Identity ResetIdentityOwner (1: IdentityID id)
 *      throws (1: IdentityNotFound ex1, 2: OwnerNotSet ex2)
 */

}
