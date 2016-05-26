Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:44354 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754402AbcEZPaF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 May 2016 11:30:05 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please pull NFS client changes for Linux 4.7
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-ID: <ed695df4-9072-41ae-93b0-8479873333f6@Netapp.com>
Date: Thu, 26 May 2016 11:29:59 -0400
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------5F8D8754F8BA5AB58FFC5D7E"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--------------5F8D8754F8BA5AB58FFC5D7E
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

Hi Linus,

The following changes since commit 44549e8f5eea4e0a41b487b63e616cb089922b99:

  Linux 4.6-rc7 (2016-05-08 14:38:32 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.7-1

for you to fetch changes up to c7d73af2d249f0323f5cdb171a59497ce80011fb:

  pnfs: pnfs_update_layout needs to consider if strict iomode checking is on (2016-05-26 08:40:56 -0400)


There are a few merge conflicts that were found in linux-next.  Stephen's suggested resolutions looked okay to us, so I've attached those patches for reference.

Thanks,
Anna

----------------------------------------------------------------

Anna Schumaker (2):
      NFS: Add nfs_commit_file()
      NFS: Add COPY nfs operation

Benjamin Coddington (1):
      SUNRPC: init xdr_stream for zero iov_len, page_len

Chuck Lever (21):
      NFS: Fix an LOCK/OPEN race when unlinking an open file
      sunrpc: Update RPCBIND_MAXNETIDLEN
      sunrpc: Advertise maximum backchannel payload size
      xprtrdma: Bound the inline threshold values
      xprtrdma: Limit number of RDMA segments in RPC-over-RDMA headers
      xprtrdma: Prevent inline overflow
      xprtrdma: Avoid using Write list for small NFS READ requests
      xprtrdma: Update comments in rpcrdma_marshal_req()
      xprtrdma: Allow Read list and Reply chunk simultaneously
      xprtrdma: Remove rpcrdma_create_chunks()
      xprtrdma: Use core ib_drain_qp() API
      xprtrdma: Rename rpcrdma_frwr::sg and sg_nents
      xprtrdma: Save I/O direction in struct rpcrdma_frwr
      xprtrdma: Reset MRs in frwr_op_unmap_sync()
      xprtrdma: Refactor the FRWR recovery worker
      xprtrdma: Move fr_xprt and fr_worker to struct rpcrdma_mw
      xprtrdma: Refactor __fmr_dma_unmap()
      xprtrdma: Add ro_unmap_safe memreg method
      xprtrdma: Remove ro_unmap() from all registration modes
      xprtrdma: Faster server reboot recovery
      xprtrdma: Remove qplock

Dan Carpenter (1):
      NFS: checking for NULL instead of IS_ERR() in nfs_commit_file()

Dave Wysochanski (1):
      NFS: Save struct inode * inside nfs_commit_info to clarify usage of i_lock

J. Bruce Fields (1):
      nfs: don't share mounts between network namespaces

Jeff Layton (16):
      sunrpc: plumb gfp_t parm into crcreate operation
      sunrpc: add a get_rpccred_rcu inline
      nfs: don't call nfs4_ff_layout_prepare_ds from ff_layout_get_ds_cred
      nfs: have ff_layout_get_ds_cred take a reference to the cred
      nfs: get a reference to the credential in ff_layout_alloc_lseg
      nfs: have flexfiles mirror keep creds for both ro and rw layouts
      pnfs: don't merge new ff lsegs with ones that have LAYOUTRETURN bit set
      pnfs: record sequence in pnfs_layout_segment when it's created
      pnfs: keep track of the return sequence number in pnfs_layout_hdr
      pnfs: only tear down lsegs that precede seqid in LAYOUTRETURN args
      flexfiles: remove pointless setting of NFS_LAYOUT_RETURN_REQUESTED
      flexfiles: add kerneldoc header to nfs4_ff_layout_prepare_ds
      pnfs: fix bad error handling in send_layoutget
      pnfs: lift retry logic from send_layoutget to pnfs_update_layout
      pnfs: rework LAYOUTGET retry handling
      pnfs: make pnfs_layout_process more robust

Olga Kornievskaia (1):
      Fixing oops in callback path

Shirley Ma (1):
      xprtrdma: Add rdma6 option to support NFS/RDMA IPv6

Tigran Mkrtchyan (1):
      nfs4: client: do not send empty SETATTR after OPEN_CREATE

Tom Haynes (5):
      pNFS/flexfiles: When checking for available DSes, conditionally check for MDS io
      pNFS/flexfiles: When initing reads or writes, we might have to retry connecting to DSes
      nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
      nfs/flexfiles: Use the layout segment for reading unless it a IOMODE_RW and reading is disabled
      pnfs: pnfs_update_layout needs to consider if strict iomode checking is on

Trond Myklebust (6):
      pNFS: Fix a leaked layoutstats flag
      SUNRPC: Ensure get_rpccred() and put_rpccred() can take NULL arguments
      NFSv4: Label stateids with the type
      NFSv4: Use the right stateid for delegations in setattr, read and write
      NFS: Reclaim writes via writepage are opportunistic
      pNFS/flexfile: Fix erroneous fall back to read/write through the MDS

Weston Andros Adamson (4):
      pnfs: set NFS_IOHDR_REDO in pnfs_read_resend_pnfs
      nfs: add debug to directio "good_bytes" counting
      sunrpc: add rpc_lookup_generic_cred
      nfs: avoid race that crashes nfs_init_commit

 fs/nfs/callback_proc.c                    |   9 +-
 fs/nfs/callback_xdr.c                     |  17 +-
 fs/nfs/delegation.c                       |   9 +-
 fs/nfs/delegation.h                       |   2 +-
 fs/nfs/direct.c                           |  17 +-
 fs/nfs/filelayout/filelayout.c            |   6 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 200 ++++++++----
 fs/nfs/flexfilelayout/flexfilelayout.h    |  17 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 119 +++----
 fs/nfs/internal.h                         |   1 +
 fs/nfs/nfs42.h                            |   1 +
 fs/nfs/nfs42proc.c                        | 107 ++++++-
 fs/nfs/nfs42xdr.c                         | 146 +++++++++
 fs/nfs/nfs4_fs.h                          |  12 +-
 fs/nfs/nfs4file.c                         |  23 ++
 fs/nfs/nfs4proc.c                         | 185 ++++++-----
 fs/nfs/nfs4state.c                        |  18 +-
 fs/nfs/nfs4trace.h                        |  10 +-
 fs/nfs/nfs4xdr.c                          |  43 ++-
 fs/nfs/pagelist.c                         |   6 +-
 fs/nfs/pnfs.c                             | 349 +++++++++++---------
 fs/nfs/pnfs.h                             |  17 +-
 fs/nfs/pnfs_nfs.c                         |  60 +++-
 fs/nfs/super.c                            |   9 +
 fs/nfs/write.c                            |  64 +++-
 include/linux/errno.h                     |   1 +
 include/linux/nfs4.h                      |  28 +-
 include/linux/nfs_fs_sb.h                 |   1 +
 include/linux/nfs_xdr.h                   |  30 +-
 include/linux/sunrpc/auth.h               |  26 +-
 include/linux/sunrpc/clnt.h               |   1 +
 include/linux/sunrpc/msg_prot.h           |   4 +-
 include/linux/sunrpc/xprt.h               |   1 +
 include/linux/sunrpc/xprtrdma.h           |   4 +-
 net/sunrpc/auth.c                         |   9 +-
 net/sunrpc/auth_generic.c                 |  13 +-
 net/sunrpc/auth_gss/auth_gss.c            |   6 +-
 net/sunrpc/auth_unix.c                    |   6 +-
 net/sunrpc/clnt.c                         |  17 +
 net/sunrpc/xdr.c                          |   2 +
 net/sunrpc/xprtrdma/backchannel.c         |  16 +
 net/sunrpc/xprtrdma/fmr_ops.c             | 134 +++++---
 net/sunrpc/xprtrdma/frwr_ops.c            | 214 +++++++------
 net/sunrpc/xprtrdma/physical_ops.c        |  39 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c            | 517 ++++++++++++++++++------------
 net/sunrpc/xprtrdma/transport.c           |  16 +-
 net/sunrpc/xprtrdma/verbs.c               |  78 +----
 net/sunrpc/xprtrdma/xprt_rdma.h           |  47 ++-
 net/sunrpc/xprtsock.c                     |   6 +
 49 files changed, 1764 insertions(+), 899 deletions(-)

--------------5F8D8754F8BA5AB58FFC5D7E
Content-Type: message/rfc822;
	name="linux-next: build failure after merge of the nfs tree.eml"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-next: build failure after merge of the nfs tree.eml"

Received: from HIOEXCMBX03-PRD.hq.netapp.com (10.122.105.36) by
 HIOEXCMBX05-PRD.hq.netapp.com (10.122.105.38) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6 via Mailbox Transport; Wed, 18 May 2016 17:58:52 -0700
Received: from VMWEXCHTS03-PRD.hq.netapp.com (10.122.105.31) by
 hioexcmbx03-prd.hq.netapp.com (10.122.105.36) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6; Wed, 18 May 2016 17:58:52 -0700
Received: from mx141.netapp.com (10.120.60.89) by
 VMWEXCHTS03-PRD.hq.netapp.com (10.122.105.31) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6; Wed, 18 May 2016 17:58:52 -0700
IronPort-PHdr: 9a23:jNioZhHgzPW3JVKlFjP7SJ1GYnF86YWxBRYc798ds5kLTJ75r8WwAkXT6L1XgUPTWs2DsrQf27uQ6PmrAzJIyK3CmU5BWaQEbwUCh8QSkl5oK+++Imq/EsTXaTcnFt9JTl5v8iLzG0FUHMHjew+a+SXqvnYsExnyfTB4Ov7yUtaLyZ/nhqbpotaJPU1hv3mUX/BbFF2OtwLft80b08NJC50a7V/3mEZOYPlc3mhyJFiezF7W78a0+4N/oWwL46pyv+YJa6jxfrw5QLpEF3xmdjltvIy4/SXEGDeV4X0QGkAHkR5FCRXe8FmuQo32tCe8s/t+3CSQINbqZb4lQnK/7qAtThi+2wkdMDtsy33aksx9iuphpw6huBF7x8aAe4+PHPF3eKmbdM4HSixGRMkXXjEXUdD0VJcGE+dUZbUQlIL6vVZb6ELmXQQ=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: A0CBAADtDj1XcEOQFmddHAGEbqVPAwEGlCIBDYFoDReFeoFBOBQBAQEBAQEBAREBCg0JByMvgi2CFQECASoTBgEBNwErAwECCjRADhOILrB+hSgBAQWNDQEBAQEGAgEcCIQbgUKMHEuCRogBhxaJGY4WCo8aj0keAQGCO4IGKjKIBgEBAQ
X-IPAS-Result: A0CBAADtDj1XcEOQFmddHAGEbqVPAwEGlCIBDYFoDReFeoFBOBQBAQEBAQEBAREBCg0JByMvgi2CFQECASoTBgEBNwErAwECCjRADhOILrB+hSgBAQWNDQEBAQEGAgEcCIQbgUKMHEuCRogBhxaJGY4WCo8aj0keAQGCO4IGKjKIBgEBAQ
X-IronPort-AV: E=Sophos;i="5.26,331,1459839600";
   d="scan'208";a="119429408"
X-Amp-Result: Clean
X-Amp-File-Uploaded: False
X-SBRS: 1.2
Received: from ozlabs.org ([103.22.144.67])
  by mx141.netapp.com with ESMTP/TLS/ADH-AES256-GCM-SHA384; 18 May 2016 17:58:52 -0700
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 3r9CPQ17BSz9t5x;
	Thu, 19 May 2016 10:58:50 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201601; t=1463619530;
	bh=fvCpX6Uejolqru70CgziS6bwVDyArRvJQ6i9Xl6OFYw=;
	h=Date:From:To:Cc:Subject:From;
	b=HbKywusH2AyaxU+QeoFoUOpnzGs4BUUQOC2fb1Vwr3xVyL4RPhNLagMy8p0KEG1ha
	 iD4UE/J+5xlLLhHjUFVxpZ0O4Sis0j9SaD+KCtruOr3F8IGPNj/XPN6+P9stWEcYBp
	 ZU/kgTa5XARbDQ4+4ohg6y4req8UBEZVCHwfWE74=
Date: Thu, 19 May 2016 10:58:47 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>, Anna
 Schumaker <Anna.Schumaker@netapp.com>, Al Viro <viro@zeniv.linux.org.uk>,
	Linus <torvalds@linux-foundation.org>
Subject: linux-next: build failure after merge of the nfs tree
Message-ID: <20160519105847.2b05c81f@canb.auug.org.au>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-Path: sfr@canb.auug.org.au
X-MS-Exchange-Organization-Network-Message-Id: e6ff265c-3206-47e3-ad24-08d37f80bee6
X-MS-Exchange-Organization-AVStamp-Enterprise: 1.0
X-MS-Exchange-Organization-AuthSource: VMWEXCHTS03-PRD.hq.netapp.com
X-MS-Exchange-Organization-AuthAs: Anonymous
MIME-Version: 1.0

Hi Trond,

After merging the nfs tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

In file included from include/linux/fs.h:19:0,
                 from fs/nfs/nfs42proc.c:4:
fs/nfs/nfs42proc.c: In function 'nfs42_proc_copy':
fs/nfs/nfs42proc.c:212:30: error: 'struct inode' has no member named 'i_mutex'
   mutex_lock(&file_inode(dst)->i_mutex);
                              ^
include/linux/mutex.h:146:44: note: in definition of macro 'mutex_lock'
 #define mutex_lock(lock) mutex_lock_nested(lock, 0)
                                            ^
fs/nfs/nfs42proc.c:215:32: error: 'struct inode' has no member named 'i_mutex'
   mutex_unlock(&file_inode(dst)->i_mutex);
                                ^   

Caused by commit

  2e72448b07dc ("NFS: Add COPY nfs operation")

interacting with commit

  9902af79c01a ("parallel lookups: actual switch to rwsem")

from Linus' tree.

I applied the following merge fix patch - you will need to send this to
Linus when you ask him to merge your tree.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 19 May 2016 10:50:26 +1000
Subject: [PATCH] nfs: fix for i_mutex to i_rwsem change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 fs/nfs/nfs42proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 20c44d1209dc..aa03ed09ba06 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -209,10 +209,10 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	dst_exception.state = dst_lock->open_context->state;
 
 	do {
-		mutex_lock(&file_inode(dst)->i_mutex);
+		inode_lock(file_inode(dst));
 		err = _nfs42_proc_copy(src, pos_src, src_lock,
 				       dst, pos_dst, dst_lock, count);
-		mutex_unlock(&file_inode(dst)->i_mutex);
+		inode_unlock(file_inode(dst));
 
 		if (err == -ENOTSUPP) {
 			err = -EOPNOTSUPP;
-- 
2.7.0

-- 
Cheers,
Stephen Rothwell

--------------5F8D8754F8BA5AB58FFC5D7E
Content-Type: message/rfc822;
	name="linux-next: manual merge of the nfs tree with Linus' tree.eml"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="linux-next: manual merge of the nfs tree with Linus' tree.em";
	filename*1="l"

Received: from HIOEXCMBX07-PRD.hq.netapp.com (10.122.105.40) by
 HIOEXCMBX05-PRD.hq.netapp.com (10.122.105.38) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6 via Mailbox Transport; Wed, 18 May 2016 17:40:46 -0700
Received: from VMWEXCHTS04-PRD.hq.netapp.com (10.122.105.32) by
 hioexcmbx07-prd.hq.netapp.com (10.122.105.40) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6; Wed, 18 May 2016 17:40:46 -0700
Received: from mx143.netapp.com (10.120.60.85) by
 VMWEXCHTS04-PRD.hq.netapp.com (10.122.105.32) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6; Wed, 18 May 2016 17:40:45 -0700
IronPort-PHdr: 9a23:iWxGHBN+8uUH7FtYeA4l6mtUPXoX/o7sNwtQ0KIMzox0KPTyrarrMEGX3/hxlliBBdydsKIVzbGP+Pq+EUU7or+/81k6OKRWUBEEjchE1ycBO+WiTXPBEfjxciYhF95DXlI2t1uyMExSBdqsLwaK+i760zceF13FOBZvIaytQ8iJ35XxjLn5ocObSj4LrQT+SIs6FA+xowTVu5teqqpZAYF19CH0pGBVcf9d32JiKAHbtR/94sCt4MwrqHwI6LoJvvRNWqTifqk+UacQTHF/azh0t4XXskz/VwyJ6jM5Q2YSnxBVGBSNuA3gWZH99C7rte5w0jSBIeX4XKtyRDWlqaFsHkzGkiACYgUl/XnXh8o4tqVHoA2soxg3l5XaeqmePfx0OKrAYNxcQnBOGM9MAX8SSrigZpcCWrJSdd1TqJPw8h5X9UOz
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: A8DrAQAACz1X/wA5ASSIgAEAAl0cAYJwASmBVKVNAQEDAQaUIgENgXUShX+BQDgUAQEBAQEBAQFkJ4ItgkMTBgEBNwE7NE6IQ7BthSgBAQWNDwEBAQcfCIQbgUKMHAtAgkaTNoR6jhYKjxqPSR4BAUKBeYIGKjKIBgEBAQ
X-IPAS-Result: A8DrAQAACz1X/wA5ASSIgAEAAl0cAYJwASmBVKVNAQEDAQaUIgENgXUShX+BQDgUAQEBAQEBAQFkJ4ItgkMTBgEBNwE7NE6IQ7BthSgBAQWNDwEBAQcfCIQbgUKMHAtAgkaTNoR6jhYKjxqPSR4BAUKBeYIGKjKIBgEBAQ
X-IronPort-AV: E=Sophos;i="5.26,331,1459839600";
   d="scan'208";a="115278843"
X-Amp-Result: Clean
X-Amp-File-Uploaded: False
X-SBRS: None
Received: from ozlabs.org ([IPv6:2401:3900:2:1::2])
  by mx143.netapp.com with ESMTP/TLS/ADH-AES256-GCM-SHA384; 18 May 2016 17:40:46 -0700
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 3r9C0Q6tTgz9t6Y;
	Thu, 19 May 2016 10:40:38 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201601; t=1463618439;
	bh=d6OxbcTr2iIBHiW3R4b6MdbiIJ5MkRjU61rsTWDvnt0=;
	h=Date:From:To:Cc:Subject:From;
	b=ojyEtlHfxCy6plpCcr2GwZZERwqZYomEoFfkQSd5PaxmhaJj624cEAy2RSQp45nTl
	 9arfr45gtrul1zmgUUsAY+PQUDGScON8PQBCaCLwxkN89pc4UI6OJsESW7MBqeobO2
	 iAwBf2D2SQ96Goz/lXWxheTePA2qJQ4uGgLmvJTI=
Date: Thu, 19 May 2016 10:40:36 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>, "Christoph
 Hellwig" <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, "Weston Andros
 Adamson" <dros@primarydata.com>, Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: linux-next: manual merge of the nfs tree with Linus' tree
Message-ID: <20160519104036.3f1ac7cf@canb.auug.org.au>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-Path: sfr@canb.auug.org.au
X-MS-Exchange-Organization-Network-Message-Id: c4d7fea4-5039-4a42-bd68-08d37f7e3748
X-MS-Exchange-Organization-AVStamp-Enterprise: 1.0
X-MS-Exchange-Organization-AuthSource: VMWEXCHTS04-PRD.hq.netapp.com
X-MS-Exchange-Organization-AuthAs: Anonymous
MIME-Version: 1.0

Hi Trond,

Today's linux-next merge of the nfs tree got a conflict in:

  fs/nfs/direct.c

between commit:

  c8b8e32d700f ("direct-io: eliminate the offset argument to ->direct_IO")

from Linus' tree and commit:

  ed3743a6d4f3 ("nfs: add debug to directio "good_bytes" counting")

from the nfs tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc fs/nfs/direct.c
index 741a92c470bb,7f03163b5364..000000000000
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@@ -591,8 -596,8 +594,8 @@@ ssize_t nfs_file_direct_read(struct kio
  		goto out_unlock;
  
  	dreq->inode = inode;
- 	dreq->bytes_left = count;
+ 	dreq->bytes_left = dreq->max_count = count;
 -	dreq->io_start = pos;
 +	dreq->io_start = iocb->ki_pos;
  	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
  	l_ctx = nfs_get_lock_context(dreq->ctx);
  	if (IS_ERR(l_ctx)) {

--------------5F8D8754F8BA5AB58FFC5D7E
Content-Type: message/rfc822;
	name="linux-next: manual merge of the rdma tree with the nfs tree.eml"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="linux-next: manual merge of the rdma tree with the nfs tree.";
	filename*1="eml"

Received: from HIOEXCMBX02-PRD.hq.netapp.com (10.122.105.35) by
 HIOEXCMBX05-PRD.hq.netapp.com (10.122.105.38) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6 via Mailbox Transport; Wed, 18 May 2016 18:54:05 -0700
Received: from VMWEXCHTS03-PRD.hq.netapp.com (10.122.105.31) by
 hioexcmbx02-prd.hq.netapp.com (10.122.105.35) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6; Wed, 18 May 2016 18:54:05 -0700
Received: from mx142.netapp.com (10.120.60.83) by
 VMWEXCHTS03-PRD.hq.netapp.com (10.122.105.31) with Microsoft SMTP Server
 (TLS) id 15.0.1156.6; Wed, 18 May 2016 18:54:04 -0700
IronPort-PHdr: 9a23:A/OlWxQZyXOQrfIZdwAPwjMy8dpsv+yvbD5Q0YIujvd0So/mwa65ZhGN2/xhgRfzUJnB7Loc0qyN4/GmAjVLvcnJmUtBWaIPfidNsd8RkQ0kDZzNImzAB9muURYHGt9fXkRu5XCxPBsdMs//Y1rPvi/6tmZKSV3BPAZ4bt74BpTVx5zukbviqtuIOk4U23KUWvBbElaflU3prM4YgI9veO4a6yDihT92QdlQ3n5iPlmJnhzxtY+a9Z9n9DlM6bp6r5YTGY2zRakzTKRZATI6KCh1oZSz7ViQBTeIs1cbT2pethdEDQ/f4FmuUpP8viX9rOZVwiSWPcTqC7szXGLmp5txTxnkwAIWNDo0+nzMloQkkLhcph7nog18x4PefZqJHPRvZeXAfNRcQ20XDehLUCkUOZ+xd4sCCaI7OvpYsIT5oxNathWkLQKlAumpwyJViTnxx6J82vl3QlKO5xApA99b6Cecl97yLqpHFLntlKQ=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: A0C7AADXGz1XcEOQFmddHAGEbqVWBpQwgXUShX+BQzkTAQEBAQEBAQERAQoNCQcjL4ItgkMTBgEBNwEoEzROAYhAsQCFKAEBBY0dAQEBAQEFAgEcCIQbgUKMHAtAgkaIAYcWhB+Eeo4WCo8aj0khAYI5ggYqMogGAQEB
X-IPAS-Result: A0C7AADXGz1XcEOQFmddHAGEbqVWBpQwgXUShX+BQzkTAQEBAQEBAQERAQoNCQcjL4ItgkMTBgEBNwEoEzROAYhAsQCFKAEBBY0dAQEBAQEFAgEcCIQbgUKMHAtAgkaIAYcWhB+Eeo4WCo8aj0khAYI5ggYqMogGAQEB
X-IronPort-AV: E=Sophos;i="5.26,332,1459839600";
   d="scan'208";a="111832485"
X-Amp-Result: Clean
X-Amp-File-Uploaded: False
X-SBRS: 1.2
Received: from ozlabs.org ([103.22.144.67])
  by mx142.netapp.com with ESMTP/TLS/ADH-AES256-GCM-SHA384; 18 May 2016 18:54:06 -0700
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 3r9Dd35CVVz9vK1;
	Thu, 19 May 2016 11:53:59 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201601; t=1463622839;
	bh=ZH74Y7ggCEKG7Je99e6I7wDOOr4fyDS34VQOr2phB0A=;
	h=Date:From:To:Cc:Subject:From;
	b=QeUqmzJU+ojB53NB2cv1uaUYfZG9IgsQbAlTyKbo0XLLYP9dTMddtnDwoKmNbOZQQ
	 dwwdovhptQMGF/pYAn7J6N1WCwaHKjgFLX+xbd3uJ3UAZ18fbfMYj5ENJFQkEREo/z
	 JQo2zO+3fUO6zfLdTbK8hOgX3d6NskhXAo3zi7t4=
Date: Thu, 19 May 2016 11:53:57 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Doug Ledford <dledford@redhat.com>, Trond Myklebust
	<trond.myklebust@fys.uio.no>
CC: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>, "Christoph
 Hellwig" <hch@lst.de>, Bart Van Assche <bart.vanassche@sandisk.com>, "Chuck
 Lever" <chuck.lever@oracle.com>, Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: linux-next: manual merge of the rdma tree with the nfs tree
Message-ID: <20160519115357.23f7e19d@canb.auug.org.au>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-Path: sfr@canb.auug.org.au
X-MS-Exchange-Organization-Network-Message-Id: 430fe9f5-3cc4-4487-c72a-08d37f887540
X-MS-Exchange-Organization-AVStamp-Enterprise: 1.0
X-MS-Exchange-Organization-AuthSource: VMWEXCHTS03-PRD.hq.netapp.com
X-MS-Exchange-Organization-AuthAs: Anonymous
MIME-Version: 1.0

Hi Doug,

Today's linux-next merge of the rdma tree got a conflict in:

  net/sunrpc/xprtrdma/frwr_ops.c

between commit:

  55fdfce101a0 ("xprtrdma: Rename rpcrdma_frwr::sg and sg_nents")

from the nfs tree and commits:

  ff2ba9936591 ("IB/core: Add passing an offset into the SG to ib_map_mr_sg")
  9aa8b3217ed3 ("IB/core: Enhance ib_map_mr_sg()")

from the rdma tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sunrpc/xprtrdma/frwr_ops.c
index a192b91ad67e,94c3fa910b85..000000000000
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@@ -450,10 -421,10 +450,10 @@@ frwr_op_map(struct rpcrdma_xprt *r_xprt
  		return -ENOMEM;
  	}
  
- 	n = ib_map_mr_sg(mr, frmr->fr_sg, frmr->fr_nents, PAGE_SIZE);
 -	n = ib_map_mr_sg(mr, frmr->sg, frmr->sg_nents, NULL, PAGE_SIZE);
 -	if (unlikely(n != frmr->sg_nents)) {
++	n = ib_map_mr_sg(mr, frmr->fr_sg, frmr->fr_nents, NULL, PAGE_SIZE);
 +	if (unlikely(n != frmr->fr_nents)) {
  		pr_err("RPC:       %s: failed to map mr %p (%u/%u)\n",
 -		       __func__, frmr->fr_mr, n, frmr->sg_nents);
 +		       __func__, frmr->fr_mr, n, frmr->fr_nents);
  		rc = n < 0 ? n : -EINVAL;
  		goto out_senderr;
  	}

--------------5F8D8754F8BA5AB58FFC5D7E--
