Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61788 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061Ab1A1RlJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 12:41:09 -0500
Received: by qyj19 with SMTP id 19so1127151qyj.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 Jan 2011 09:41:07 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFS: NFSv4 readdir loses entries
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 28 Jan 2011 12:41:05 -0500
Message-ID: <20110128174105.3235.21014.stgit@matisse.1015granger.net>
In-Reply-To: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
References: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On recent 2.6.38-rc kernels, connectathon basic test 6 fails on
NFSv4 mounts of OpenSolaris with something like:

> ./test6: readdir
> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.12' dir entry, pass 0
> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.82' dir entry, pass 0
> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.164' dir entry, pass 0
> 	./test6: (/mnt/klimt/matisse.test) Test failed with 3 errors
> basic tests failed
> Tests failed, leaving /mnt/klimt mounted
> [cel@matisse cthon04]$

I narrowed the problem down to nfs4_decode_direct() reporting that the
decode buffer had overflowed while decoding the entries for those
missing files.

verify_attr_len() assumes both it's pointer arguments reside on the
same page.  When these arguments point to locations on two different
pages, verify_attr_len() can report false errors.  This can happen now
that a large NFSv4 readdir result can span pages.

We have reasonably good checking in nfs4_decode_dirent() anyway, so
it should be safe to simply remove the extra checking.

At a guess, this was introduced by commit 6650239a, "NFS: Don't use
vm_map_ram() in readdir".

Cc: stable@kernel.org [2.6.37]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 009aef9..4e2c168 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6132,9 +6132,6 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (entry->fattr->valid & NFS_ATTR_FATTR_TYPE)
 		entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
 
-	if (verify_attr_len(xdr, p, len) < 0)
-		goto out_overflow;
-
 	return 0;
 
 out_overflow:

