From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 0/67] nfs41 client patch for 2.6.30
Date: Thu, 02 Apr 2009 16:46:17 +0300
Message-ID: <49D4C1A9.5060900@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31711 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756245AbZDBNrb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:47:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

I've integrated the latest client patches from Andy
(with a few minor changes listed below) and updated
git://linux-nfs.org/~bhalevy/linux-pnfs.git
branches:
	nfs41-for-next
	nfs41-for-2.6.30
	nfs41

nfs41-for-{next,2.6.30} contain all non-backchannel patches
rebased onto {v2.6.29,nfs-2.6/for-next} respectively.

nfs41 contains the backchannel patches on top of nfs41-for-2.6.30.

changes since v1:
- fixed bisectability issues
- got rid of rpc_clnt.cl_private, use *session in seq args/res instead
- remove ifdefs around nfs_client_initdata.minorversion
- use kcalloc to allocate slot table
- alloc session with GFP_KERNEL
- moved nfs4_init_slot_table's definition from "sessions client infrastructure"
  to first usage, in "create_session operations".
- embed resp_len in nfs_getaclres
- moved new xdr op args/res definitions away from "client xdr definitions",
  to where they're first used.
- move find_slot and free_slot closer to where they're first used.
- Revert "NFS: fix decode_fs_locations_maxsz"
- nfs41: get fs_locations replen before encoding the GETATTR
- nfs41: get getacl replen before encoding the GETATTR

(changes from Andy's set)
- getaclres moved into right patch
- dropped "nfs41: stubs for nfs41 procedures"
- edited create_session, destroy_session, session setup, and session_reset
  for proc_{create,destroy}_session interface.
- reverse EXCHGID4_INVAL_FLAG_MASK_{A,R}

Here's the list of patches:

[PATCH v2 01/67] nfs41: common protocol definitions
[PATCH v2 02/67] nfs41: Add Kconfig symbols for NFSv4.1
[PATCH v2 03/67] nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
[PATCH v2 04/67] nfs41: add mount command option minorversion
[PATCH v2 05/67] nfs41: nfs_client.cl_minorversion
[PATCH v2 06/67] nfs41: Use mount minorversion option
[PATCH v2 07/67] nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
[PATCH v2 08/67] nfs41: client xdr definitions
[PATCH v2 09/67] nfs41: sessions client infrastructure
[PATCH v2 10/67] nfs41: use nfs4_server_caps_arg
[PATCH v2 11/67] nfs41: use nfs4_readlink_res
[PATCH v2 12/67] nfs41: use nfs4_statfs_res
[PATCH v2 13/67] nfs41: use nfs4_fsinfo_res
[PATCH v2 14/67] nfs41: use nfs4_pathconf_res
[PATCH v2 15/67] nfs41: use nfs4_getaclres
[PATCH v2 16/67] NFS: get rid of unused xdr decode_setattr(, res) argument
[PATCH v2 17/67] nfs41: use nfs4_setaclres
[PATCH v2 18/67] nfs41: use nfs4_fs_locations_res
[PATCH v2 19/67] nfs41: introduce nfs4_call_sync
[PATCH v2 20/67] nfs41: nfs41: pass *session in seq_args and seq_res
[PATCH v2 21/67] nfs41: set up seq_res.sr_slotid
[PATCH v2 22/67] NFS: use decode_change_info_maxsz for xdr maxsz calculations
[PATCH v2 23/67] NFS: define and initialize compound_hdr.replen
[PATCH v2 24/67] NFS: update hdr->replen for every encode op
[PATCH v2 25/67] NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset
[PATCH v2 26/67] nfs41: encode minorversion in compound header
[PATCH v2 27/67] nfs41: xdr {encode,decode}_sequence
[PATCH v2 28/67] nfs41: nfs4_setup_sequence
[PATCH v2 29/67] nfs41: find slot
[PATCH v2 30/67] nfs41: setup_sequence method
[PATCH v2 31/67] nfs41: free slot
[PATCH v2 32/67] nfs41: nfs41_sequence_free_slot
[PATCH v2 33/67] nfs41: nfs41_sequence_done
[PATCH v2 34/67] nfs41: nfs41_call_sync_done
[PATCH v2 35/67] nfs41: close sequence setup/done support
[PATCH v2 36/67] nfs41: open sequence setup/done support
[PATCH v2 37/67] nfs41: lock sequence setup/done support
[PATCH v2 38/67] nfs41: locku sequence setup/done support
[PATCH v2 39/67] nfs41: unlink sequence setup/done support
[PATCH v2 40/67] nfs41: read sequence setup/done support
[PATCH v2 41/67] nfs41 write sequence setup done support
[PATCH v2 42/67] nfs41 commit sequence setup done support
[PATCH v2 43/67] nfs41 delegreturn sequence setup done support
[PATCH v2 44/67] nfs41: exchange_id operation
[PATCH v2 45/67] nfs41: get_lease_time
[PATCH v2 46/67] nfs41: create_session operation
[PATCH v2 47/67] nfs41: verify session channel attribues
[PATCH v2 48/67] nfs41: use session attributes for rsize and wsize
[PATCH v2 49/67] nfs41: destroy_session operation
[PATCH v2 50/67] nfs41: enable nfs_client only nfs4_async_handle_error
[PATCH v2 51/67] nfs41: sequence operation
[PATCH v2 52/67] nfs41: reset the session slot table
[PATCH v2 53/67] nfs41: add session setup to the state manager
[PATCH v2 54/67] nfs41: add session reset to state manager
[PATCH v2 55/67] nfs41: sunrpc: Export the call prepare state for session reset
[PATCH v2 56/67] nfs41: use rpc prepare call state for session reset
[PATCH v2 57/67] nfs41: kick start nfs41 session recovery when handling errors
[PATCH v2 58/67] nfs41: schedule async session reset
[PATCH v2 59/67] nfs41: lease renewal
[PATCH v2 60/67] nfs41: support minorversion 1 for nfs4_check_lease
[PATCH v2 61/67] nfs41: introduce get_state_renewal_cred
[PATCH v2 62/67] nfs41: establish sessions-based clientid
[PATCH v2 63/67] nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
[PATCH v2 64/67] nfs41: get_clid_cred for EXCHANGE_ID
[PATCH v2 65/67] nfs41: recover lease in _nfs4_lookup_root
[PATCH v2 66/67] nfs41: fail mount on EXCHANGE_ID, CREATE_SESSION failure
[PATCH v2 67/67] nfs41: increment_{open,lock}_seqid
