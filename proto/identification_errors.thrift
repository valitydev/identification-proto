namespace java dev.vality.damsel.identity.errors
namespace erlang identity_err


union IdentificationFailure {
    1: GeneralFailure unknown
    2: GeneralFailure invalid_documents
    3: GeneralFailure owner_authorization_failed
}

struct GeneralFailure {}