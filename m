Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:63855 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaBCVB7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 16:01:59 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: Fix READDIR oops with NFSv4 on RDMA
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 03 Feb 2014 16:01:58 -0500
Message-ID: <20140203210157.3533.84148.stgit@manet.1015granger.net>
In-Reply-To: <20140203205903.3533.39213.stgit@manet.1015granger.net>
References: <20140203205903.3533.39213.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When starting the Connectathon basic tests on an NFSv4 RDMA
mount, I encountered this oops:

  BUG: unable to handle kernel NULL pointer dereference at (null)
  IP: [<ffffffff8129cc56>] memcpy+0x6/0x110
  PGD 2106cd067 PUD 20fef9067 PMD 0
  Oops: 0000 [#1] SMP

 ...

  [<ffffffffa05dc1b1>] ? xdr_inline_decode+0xb1/0x120 [sunrpc]
  [<ffffffffa071f19c>] nfs4_decode_dirent+0x4c/0x250 [nfsv4]
  [<ffffffff81178a02>] ? alloc_pages_current+0xb2/0x170
  [<ffffffffa06a1225>] nfs_readdir_page_filler+0xe5/0x2c0 [nfs]
  [<ffffffffa06a1622>] nfs_readdir_xdr_to_array+0x222/0x2e0 [nfs]
  [<ffffffffa06a1702>] nfs_readdir_filler+0x22/0x90 [nfs]
  [<ffffffff8112f975>] ? add_to_page_cache_lru+0x35/0x50
  [<ffffffff8112faee>] __read_cache_page+0x7e/0xe0
  [<ffffffffa06a16e0>] ? nfs_readdir_xdr_to_array+0x2e0/0x2e0 [nfs]
  [<ffffffffa06a16e0>] ? nfs_readdir_xdr_to_array+0x2e0/0x2e0 [nfs]
  [<ffffffff8113079c>] do_read_cache_page+0x3c/0x110
  [<ffffffff811308b9>] read_cache_page_async+0x19/0x20
  [<ffffffff811308ce>] read_cache_page+0xe/0x20
  [<ffffffffa06a1c1e>] nfs_readdir+0x14e/0x3d0 [nfs]
  [<ffffffffa071f150>] ? decode_pathconf+0x1c0/0x1c0 [nfsv4]
  [<ffffffff811a811d>] iterate_dir+0xad/0xd0
  [<ffffffff811a71ca>] ? do_fcntl+0x28a/0x370
  [<ffffffff811a82d5>] SyS_getdents+0x95/0x100
  [<ffffffff811a83e0>] ? SyS_old_readdir+0xa0/0xa0
  [<ffffffff815a7752>] system_call_fastpath+0x16/0x1b

The problem does not occur with NFSv3 over RDMA.

nfs4_decode_dirent() is confused because the xdr_buf's page vector
starts long after the first directory entry in the server's reply.

Commit aa9c2669, "NFS: Client implementation of Labeled-NFS," is
reported by git bisect as the first bad commit.

This commit changes the decode_readdir_maxsz macro.  This macro
controls where the generic XDR routines split incoming readdir reply
data between the head[0] buffer and the page cache.

Security labels go with each directory entry, thus they are always
stored in the page cache, not in the head buffer.  The length of the
reply that goes in head[0] should not change.

I've reverted the change to decode_readdir_maxsz.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=68371
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: <stable@vger.kernel.org> # 3.11+
---

 fs/nfs/nfs4xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5be2868..79e1d02 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -203,8 +203,7 @@ static int nfs4_stat_to_errno(int);
 				 2 + encode_verifier_maxsz + 5 + \
 				nfs4_label_maxsz)
 #define decode_readdir_maxsz	(op_decode_hdr_maxsz + \
-				 decode_verifier_maxsz + \
-				nfs4_label_maxsz + nfs4_fattr_maxsz)
+				 decode_verifier_maxsz)
 #define encode_readlink_maxsz	(op_encode_hdr_maxsz)
 #define decode_readlink_maxsz	(op_decode_hdr_maxsz + 1)
 #define encode_write_maxsz	(op_encode_hdr_maxsz + \

