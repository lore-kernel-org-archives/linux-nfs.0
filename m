From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/7] nfs41-for-2.6.30 cleanup patches
Date: Mon, 30 Mar 2009 16:59:01 +0300
Message-ID: <49D0D025.2080608@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:6523 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751036AbZC3N7H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 09:59:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

The following cleanup patches address your review comments.
They are tested to compile and I'll test them on hardware ASAP.
Once ready, I'd like to squash them in to the patchset and
resend a new version.

[PATCH 1/7] SQUASHME: nfs41: remove ifdefs around nfs_client_initdata.minorversion
[PATCH 2/7] SQUASHME: nfs41: use kcalloc to allocate slot table
[PATCH 3/7] SQUASHME: nfs41: alloc session with GFP_KERNEL
[PATCH 4/7] SQUASHME: nfs41: embed resp_len in nfs_getaclres
[PATCH 5/7] SQUASHME: Revert "NFS: fix decode_fs_locations_maxsz"
[PATCH 6/7] SQUASHME: nfs41: get fs_locations replen before encoding the GETATTR
[PATCH 7/7] SQUASHME: nfs41: get getacl replen before encoding the GETATTR

Other than that I've made the following changes to be included
in the next version:

- fixed bisectability issues
- got rid of rpc_clnt.cl_private, use *session in seq args/res instead
- moved nfs4_init_slot_table's definition from "sessions client infrastructure"
  to first usage, in "create_session operations".
- moved new xdr op args/res definitions away from "client xdr definitions",
  to where they're first used.
- move find_slot and free_slot closer to where they're first used.

Benny
