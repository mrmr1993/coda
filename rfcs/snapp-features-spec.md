# Snapp protocol features spec

The purpose of this document is to examine the high-level features that should
be available to developers building on the snapp platform. This should be used
to inform the design of the snapp transaction architecture.

Out of scope for this document are: specific features that do not rely on
protocol-level interactions (e.g. cryptographic primitives within snapps, http
requests validated by snapps), or otherwise fall within developer tooling (e.g.
specific APIs for snapp composition, deployment tools, browser support) except
where these require specific changes to the protocol.

# Overview of candidate features

* [x] Support for arbitrary computation / statement verification
* [x] Access to private data during snapp computations
* [x] Sending transactions authorized by snapps
* [x] Issuing transactions as part of a snapp transaction
* [x] Instantiating other snapps as part of a snapp transaction 
* [x] Modelling snapp execution as function evaluation
* [x] Querying the 'invoker' of the snapp
* [x] Querying elements of protocol / blockchain state
* [x] Reading and writing snapp-specific state
* [x] Coordinated access to snapp-specific state
* [x] Uncoordinated, distributed access to public snapp-specific state
* [ ] On-chain computation of snapp-specific state updates
* [x] On-chain availability of snapp-specific state updates
* [ ] On-chain accumulation of snapp-specific state updates
* [x] Delayed accumulation of snapp-specific state updates
* [x] Support for account balances / transfers in non-mina tokens

(TODO: Finalize this list)

# Candidate features

## Support for arbitrary computation / statement verification

This feature allows users to write applications to perform arbitrary
computations or to verify arbitrary statements, in order to express
applications within the snapp platform.

* [x] This is a target feature.

### Implementation details

This is supported out-of-the-box by zk proof primitives.

## Access to private data during snapp computations

This feature allows users to handle private or secret information during the
course of running a snapp, and to perform arbitrary computations using that
data.

* [x] This is a target feature.

### Implementation details

This is supported out-of-the-box by zk proof primitives.

## Sending transactions authorized by snapps

This feature allows transfers to and from mina accounts to be controlled by
snapp proofs, instead of or in addition to signatures. This allows users to
create shared access to funds, or to create restrictions on where the funds may
be moved to / from.

* [x] This is a target feature.

### Implementation details

Accounts have a 'permissions' field, which determines whether a signature or a
snapp proof (or either) should be provided to issue certain kinds of
transactions involving that account. If a snapp permission is available and
used, the snapp proof must be valid against the verification key stored in the
account.

This requires the use of existing fields in the account record. No new fields
need to be added.

## Issuing transactions as part of a snapp transaction

This feature allows snapp developers to move funds or otherwise interact with
accounts the mina ledger as part of their snapp applications.

* [x] This is a target feature.

### Implementation details

Snapps should be able to access the transactions 'bundled with' the current
snapp account interaction, by passing this information as part of the 'public
input witness' to the snapp proof. The snapp proof must verify when this
information is passed as part of the its witness.

This is encoded as a hash-consed list of transactions passed in the proof's
input, which the snapp can access and inspect as part of its circuit. This is
discussed in more detail in the [new transaction model
RFC](https://github.com/MinaProtocol/mina/blob/95e148b4eef01c6104de21e4c6c7c7465536b9d8/rfcs/0041-new-transaction-model.md),
with suggested modifications in [the solidity snapps
doc](https://github.com/MinaProtocol/mina/blob/f0ad49658d62da50ca5c16f6780fd2871b254aba/rfcs/solidity-snapps.md#function-calls-between-snapps).

This requires no further modifications to the format of transactions, nor
changes to the protocol outside of the transaction logic.

## Instantiating other snapps as part of a snapp transaction

Snapp developers should be able to invoke other snapps as part of the statement
of their snapp, so that they can use functionality provided by other snapps
without needing to recreate the other snapp applications.

* [x] This is a target feature.

### Implementation details

As above, snapps should be able to access other snapp transactions 'bundled
with' the current transaction. This is discussed in more detail in the [new
transaction model
RFC](https://github.com/MinaProtocol/mina/blob/95e148b4eef01c6104de21e4c6c7c7465536b9d8/rfcs/0041-new-transaction-model.md),
with suggested modifications in [the solidity snapps
doc](https://github.com/MinaProtocol/mina/blob/f0ad49658d62da50ca5c16f6780fd2871b254aba/rfcs/solidity-snapps.md#function-calls-between-snapps).

This requires no further modifications to the format of transactions, nor
changes to the protocol outside of the transaction logic.

## Modelling snapp execution as function evaluation

Snapps should be able to accept input and return output, matching the
tranditional programming model of non-zk-proof programming languages. For
example, a snapp should be able to provide an interface equivalent to
`getData(inputs) -> outputs` that may be invoked by other snapps, or directly
by users.

* [x] This is a target feature.

### Implementation details

The input and output values should be exposed as part of the 'public input
witness' to a snapp proof. These values should also be made available to other
snapps that instantiate them, by including this data as part of the transaction
data described above. This is mentioned briefly in [the solidity snapps doc](https://github.com/MinaProtocol/mina/blob/f0ad49658d62da50ca5c16f6780fd2871b254aba/rfcs/solidity-snapps.md#arguments-and-returned-values).

This requires additional data to be carried inside transactions. This data may
need to stored in the archive node, in order to maintain a complete record of
transactions.

## Querying the 'invoker' of the snapp

Snapp developers should be able to use the (on-chain, public-key) identity of
the originator for the current snapp execution as data in their snapp programs.

* [x] This is a target feature

### Implementation details

The 'fee payer' -- the party who pays the fee for submitting the transaction to
the chain -- should be identified as the 'invoker' of the snapp, by reference
to their fee payment within the transaction. This payment should be included
with the other transactions 'bundled with' the current transaction. This is
discussed in more detail in the [new transaction model
RFC](https://github.com/MinaProtocol/mina/blob/95e148b4eef01c6104de21e4c6c7c7465536b9d8/rfcs/0041-new-transaction-model.md).

This requires no further modifications to the format of transactions, nor
changes to the protocol outside of the transaction logic.

## Reading and writing snapp-specific state

Snapp developers should be able to retrieve some state specific to their
application while building a snapp proof, and update this data when their snapp
proof is issued.

* [x] This is a target feature

### Implementation details

* A small amount of persistent on-chain storage is held in a snapp account. A
  snapp transaction may refer to this state, by constraining this state to the
  values used in its proof using its transaction predicate. More detail given
  in the [new transaction model
  RFC](https://github.com/MinaProtocol/mina/blob/95e148b4eef01c6104de21e4c6c7c7465536b9d8/rfcs/0041-new-transaction-model.md)).
  - This requires no further modifications to the format of transactions, nor
    changes to the protocol outside of the transaction logic.
* A commitment to a larger amount of information may be held in the same
  storage as above.
  - This requires no further modifications.
* A larger amount of information may be committed to on-chain, accumulated as
  'updates' on a snapp account and exposed as part of its state, using the
  system [proposed in this GitHub
  comment](https://github.com/MinaProtocol/mina/pull/9123#issuecomment-876833564).
    - This requires additional data to be carried inside transactions, for a
      commitment to this data to be stored inside accounts, and for both of
      these to be made available from the archive node.

## Coordinated access to snapp-specific state

Snapp developers should be able to coordinate with one or more users to ensure
that they have access to and/or the ability to modify the application state.

* [x] This is a target feature

### Implementation details

The details of the specific coordination is the responsibility of individual
snapp developers. This coordination can be enforced on-chain by using a
predicate in the snapp transaction to constrain the previous state, and
referring to that previous state in the snapp while calculating the new state.

## Uncoordinated, distributed access to pubic snapp-specific state

Snapp developers should be able to expose their state from their snapps in such
a way that users can continue to access the state to run the snapps without
needing to coordinate with eachother.

* [x] This is a target feature

### Implementation details

* For a small amount state persisted on-chain, this information is available to
  any user who is synced to the chain.
  - This requires no further modifications to the format of transactions.
* For larger state, especially where it is only 'committed to' on-chain and the
  contents are stored ephemerally, state updates can be declared publicly using
  'events'. A hash of the event data will be exposed as part of the 'public
  input witness' to a snapp proof. This data is not intended to be stored
  persistently in the protocol state, but should be stored in the archive node
  for later retrieval. More detail is given in [the solidity snapps
  doc](https://github.com/MinaProtocol/mina/blob/f0ad49658d62da50ca5c16f6780fd2871b254aba/rfcs/solidity-snapps.md#events).
    - This requires additional data to be carried inside transactions, and to
      be stored in the archive node.

## On-chain computation of snapp-specific state updates

Snapp developers should be able to use the most up-to-date data available for
their snapp while updating its state.

* [ ] This is **NOT** a target feature

### Implementation details

TODO. Needs some kind of VM to reach the full potential.

## On-chain availability of snapp-specific state updates

Snapp developers and users should be able to receive or recover the updates to
the public state of a snapp by monitoring the chain.

* [x] This is a target feature

### Implementation details

* GraphQL or other endpoints to monitor a live daemon for updates to snapp
  state.
* Store historical snapp states in the archive node, for later retrieval
  - TODO: Should this be opt-in?
* Store all data from snapp transactions in the archive node, to allow state
  rebuilding (if e.g. updates / events are used to communicate some of the
  data).

This requires additional changes to the archive node, GraphQL interface, and
(maybe) CLI to expose this information.

## On-chain accumulation of snapp-specific state updates

Snapp developers should be able to provide rules that allow updates included
with their snapps to be applied sequentially on-chain, without coordination or
other interaction.

* [ ] This is **NOT** a target feature

### Implementation details

TODO. Needs some kind of VM to reach the full potential.

## Delayed accumulation of snapp-specific state updates

Snapp developers should be able to provide rules that allow updates included
with their snapps to be applied sequentially on-chain, without coordination
from their users, but with some intervention.

* [x] This is a target feature

### Implementation details

The updates may be committed to on-chain, accumulated as 'updates' on a snapp
account and exposed as part of its state, using the
system [proposed in this GitHub
comment](https://github.com/MinaProtocol/mina/pull/9123#issuecomment-876833564).
These updates are 'delayed', and the actual committed state of the snapp's
account is not otherwise updated.
These updates can then be combined (or rolled-up) by an additional rule in the
snapp, which takes the 'pending' updates that have accumulated and applies them
in order. The resulting combined state update is applied to the snapp by
sending it in an additional transaction.

This requires additional data to be carried inside transactions, for a
commitment to this data to be stored inside accounts, and for both of these to
be made available from the archive node.

## Support for account balances / transfers in non-mina tokens

Snapp developers should be able to create and manage accounts where the
balances of and transfers between accounts represent some part of the state of
their application, rather than mina tokens.

* [x] This is a target feature

### Implementation details

* These accounts are distinguished by a 'token ID' which doesn't equal to the
mina token ID (`1`).
  - This is already implemented, only testing and bugfixes needed.
* A snapp transaction to the 'token owner' account should bundled with a
  transaction involving that token, so that the behaviour of the token is
  governed by the rules of that snapp.
  - This requires some changes to the transaction logic. There is some
    discussion of the small changes needed in [this GitHub
    issue](https://github.com/MinaProtocol/mina/issues/9182). In particular,
    that the number of a particular token balance (or not) within a transaction
    should be determined by the governing snapp, and not by the usual
    transaction logic.
