From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 0/85] nfs41 client patches for review
Date: Mon, 10 Nov 2008 21:57:02 +0200
Message-ID: <4918920E.3030301@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:30812 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750865AbYKJT5H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 14:57:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

Here's the patch series for nfs41 client side, rebased
over 2.6.28 for review.

I've cleaned up the patch as much as I could in the given
time frame but surely there's more work to be done.

I encourage others to comment on the patches as well.

Thanks,

Benny

pre-nfs41 patches:
[RFC 01/85] sunrpc: get rid of rpc_rqst.rq_bufsize
[RFC 02/85] nfs: return compound hdr.status when there are no op replies
[RFC 03/85] nfs: remove incorrect usage of nfs4 compound response hdr.status
[RFC 04/85] FIXME: NFS: Increment operation number in each encode_* routine


general defs:
[RFC 05/85] nfs41: Add Kconfig symbols for NFSv4.1
[RFC 06/85] nfs41: common protocol definitions
[RFC 07/85] nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
[RFC 08/85] nfs41: client xdr definitions


basic support for minorversion != 0:
[RFC 09/85] nfs41: add mount command option minorvers
[RFC 10/85] nfs41: struct nfs_server minorversion
[RFC 11/85] nfs41: nfs_client.cl_minorversion
[RFC 12/85] nfs41: set nfs_client rpc_ops based on minorversion
[RFC 13/85] nfs41: use ptr to rpc procedures via struct nfs_client
[RFC 14/85] nfs41: sunrpc: support minorversion for rpc_clnt version table.
[RFC 15/85] nfs41: Proper initialization of nfs_client_initdata.rpc_ops
[RFC 16/85] nfs41: pass recovery status from reclaimer kthread up to nfs4_wait_clnt_recover
[RFC 17/85] nfs41: fallback to lower minorversion if nfs4_create_server fails


sessions basic functionality:
[RFC 18/85] nfs41: sessions client infrastructure
[RFC 19/85] nfs41: share client sessions across mounts
[RFC 20/85] nfs41: slot table init and destroy
[RFC 21/85] nfs41: find slot
[RFC 22/85] nfs41: free slot

support for sequence for legacy ops:
[RFC 23/85] nfs41: minorversion support for xdr
[RFC 24/85] nfs41: stubs for nfs41 procedures
[RFC 25/85] nfs41: make nfs4_wait_bit_killable public
[RFC 26/85] nfs41: introduce nfs4_call_sync
[RFC 27/85] nfs41: nfs4_setup_sequence
[RFC 28/85] nfs41: setup_sequence method
[RFC 29/85] nfs41: nfs41_sequence_done
[RFC 30/85] nfs41: nfs41_call_sync_done
[RFC 31/85] nfs41: separate free slot from sequence done
[RFC 32/85] nfs41: sequence setup/done support
[RFC 33/85] nfs41: Support sessions with O_DIRECT.

nfs41 ops:
[RFC 34/85] nfs41: exchange_id operation
[RFC 35/85] nfs41: get_lease_time
[RFC 36/85] nfs41: create_session operation
[RFC 37/85] nfs41: destroy_session operation
[RFC 38/85] nfs41: sequence operation

session setup and recovery:
[RFC 39/85] nfs41: session recovery infrastructure
[RFC 40/85] nfs41: schedule async session reset
[RFC 41/85] nfs41: lease renewal
[RFC 42/85] nfs41: sunrpc: Export the call prepare state for session reset
[RFC 43/85] nfs41: use rpc prepare call state for session reset
[RFC 44/85] nfs41: kick start nfs41 session recovery when handling errors
[RFC 45/85] nfs41: start session recovery from nfs4_setup_sequence
[RFC 46/85] nfs41: introduce get_state_renewal_cred
[RFC 47/85] nfs41: get cred in exchange_id when cred arg is NULL
[RFC 48/85] nfs41: establish sessions-based clientid
[RFC 49/85] nfs41: recover lease in _nfs4_lookup_root
[RFC 50/85] nfs41: schedule state recovery on BAD or DEAD session
[RFC 51/85] nfs41: state reclaimer renew lease error handling
[RFC 52/85] nfs41: increment_{open,lock}_seqid

backchannel:
[RFC 53/85] nfs41: Add ability to read RPC call direction on TCP stream.
[RFC 54/85] nfs41: Skip past the RPC call direction
[RFC 55/85] nfs41: Refactor NFSv4 callback service
[RFC 56/85] nfs41: client callback structures
[RFC 57/85] nfs41: Initialize new rpc_xprt callback related fields
[RFC 58/85] nfs41: New backchannel helper routines
[RFC 59/85] nfs41: New include/linux/sunrpc/bc_xprt.h
[RFC 60/85] nfs41: New xs_tcp_read_data()
[RFC 61/85] nfs41: Add backchannel processing support to RPC state machine
[RFC 62/85] nfs41: Backchannel callback service helper routines
[RFC 63/85] FIXME: nfs41: sunrpc: handle clnt==NULL in call_status

callback service:
[RFC 64/85] nfs41: Refactor svc_process()
[RFC 65/85] nfs41: Backchannel bc_svc_process()
[RFC 66/85] nfs41: Implement NFSv4.1 callback service process.
[RFC 67/85] nfs41: sunrpc: provide functions to create and destroy a svc_xprt for backchannel use
[RFC 68/85] nfs41: sunrpc: add a struct svc_xprt pointer to struct svc_serv for backchannel use
[RFC 69/85] nfs41: create a svc_xprt for nfs41 callback thread and use for incoming callbacks
[RFC 70/85] nfs41: save svc_serv in nfs_callback_info
[RFC 71/85] nfs41: Add a reference to svc_serv during callback service bring up
[RFC 72/85] nfs41: Allow NFSv4 and NFSv4.1 callback services to coexist
[RFC 73/85] nfs41: Setup the backchannel
[RFC 74/85] nfs41: Client indicates presence of NFSv4.1 callback channel.
[RFC 75/85] nfs41: Get the rpc_xprt * from the rpc_rqst instead of the rpc_clnt.
[RFC 76/85] nfs41: Release backchannel resources associated with session

callback processing:
[RFC 77/85] nfs41: store minorversion in cb_compound_hdr_arg
[RFC 78/85] nfs41: decode minorversion 1 cb_compound header
[RFC 79/85] nfs41: callback numbers definitions
[RFC 80/85] nfs41: consider minorversion in callback_xdr:process_op
[RFC 81/85] nfs41: define CB_NOTIFY_DEVICEID as not supported
[RFC 82/85] nfs41: cb_sequence protocol level data structures
[RFC 83/85] nfs41: cb_sequence proc implementation
[RFC 84/85] nfs41: cb_sequence xdr implementation
[RFC 85/85] nfs41: verify CB_SEQUENCE position in callback compound
