From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/46] nfs41 sessions infrastructure
Date: Wed, 04 Mar 2009 01:28:04 +0200
Message-ID: <49ADBD04.2090002@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17136
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754177AbZCCXl6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:41:58 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

The following patchset implements infrastructure for nfs41 sessions
in the kernel's nfs client.  The patches are based on v2.6.29-rc6
are are supposed to be fully bisactable and ready for review
and, hopefully, submission upstream.

(To see the whole context, see the full tree for nfs41 and pnfs:
git://linux-nfs.org/~bhalevy/linux-pnfs.git
The nfs41-for-2.6.30 branch holds this patchset
nfs41-latest and pnfs-all-latest are shortcuts for
the latest nfs41 and pnfs patches, respectively)

"TOC"

Misc:
[PATCH 01/46] nfs41: common protocol definitions
[PATCH 02/46] nfs41: Add Kconfig symbols for NFSv4.1

Implement the minorversion mount option:
[PATCH 03/46] nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
[PATCH 04/46] nfs41: nfs_client.cl_minorversion
[PATCH 05/46] nfs41: add mount command option minorversion
[PATCH 06/46] nfs41: Use mount minorversion option
[PATCH 07/46] nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT


Set the stage for adding nfs41 sequence args and res to xdr ops
args and res data structures:
[PATCH 08/46] nfs41: client xdr definitions
[PATCH 09/46] nfs41: sessions client infrastructure
[PATCH 10/46] nfs41: find slot
[PATCH 11/46] nfs41: free slot
[PATCH 12/46] nfs41: use nfs4_server_caps_arg
[PATCH 13/46] nfs41: use nfs4_readlink_res
[PATCH 14/46] nfs41: use nfs4_statfs_res
[PATCH 15/46] nfs41: use nfs4_fsinfo_res
[PATCH 16/46] nfs41: use nfs4_pathconf_res
[PATCH 17/46] nfs41: use nfs4_getaclres
[PATCH 18/46] NFS: get rid of unused xdr decode_setattr(, res) argument
[PATCH 19/46] nfs41: use nfs4_setaclres
[PATCH 20/46] nfs41: use nfs4_fs_locations_res

Encode minorversion in compound header:
[PATCH 21/46] sunrpc: add cl_private field to struct rpc_clnt
[PATCH 22/46] nfs41: sunrpc: use private void pointer in rpc_clnt
[PATCH 23/46] nfs41: encode minorversion in compound header


xdr scaffolding for sequence x-coding:
[PATCH 24/46] NFS: fix decode_fs_locations_maxsz
[PATCH 25/46] NFS: use decode_change_info_maxsz for xdr maxsz calculations
[PATCH 26/46] NFS: define and initialize compound_hdr.replen
[PATCH 27/46] NFS: update hdr->replen for every encode op
[PATCH 28/46] NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset
[PATCH 29/46] nfs41: xdr {encode,decode}_sequence

rpc level support for session:
[PATCH 30/46] nfs41: stubs for nfs41 procedures
[PATCH 31/46] nfs41: introduce nfs4_call_sync
[PATCH 32/46] nfs41: set up seq_res.sr_slotid
[PATCH 33/46] nfs41: nfs4_setup_sequence
[PATCH 34/46] nfs41: setup_sequence method
[PATCH 35/46] nfs41: nfs41_sequence_free_slot
[PATCH 36/46] nfs41: nfs41_sequence_done
[PATCH 37/46] nfs41: nfs41_call_sync_done
[PATCH 38/46] nfs41: close sequence setup/done support
[PATCH 39/46] nfs41: open sequence setup/done support
[PATCH 40/46] nfs41: lock sequence setup/done support
[PATCH 41/46] nfs41: locku sequence setup/done support
[PATCH 42/46] nfs41: unlink sequence setup/done support
[PATCH 43/46] nfs41: read sequence setup/done support
[PATCH 44/46] nfs41 write sequence setup done support
[PATCH 45/46] nfs41 commit sequence setup done support
[PATCH 46/46] nfs41 delegreturn sequence setup done support
