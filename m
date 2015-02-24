Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:42430 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbbBXAPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 19:15:02 -0500
Received: by iecrp18 with SMTP id rp18so27924187iec.9
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 16:15:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Nix <nix@esperi.org.uk>, Neil Brown <neilb@suse.de>
Subject: [PATCH 2/3] NFSv3: Use the readdir fileid as the mounted-on-fileid
Date: Mon, 23 Feb 2015 19:14:56 -0500
Message-Id: <1424736897-95767-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we call readdirplus, set the fileid normally returned by readdir
as the mounted-on-fileid, since that is commonly the case if there is
a mountpoint. To ensure that we get it right, we only set the flag if
the readdir fileid differs from the one returned in the readdirplus
attributes.

This again means that we can avoid the issues described in commit
2ef47eb1aee17 ("NFS: Fix use of nfs_attr_use_mounted_on_fileid()"),
which only fixed NFSv4.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3xdr.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 2a932fdc57cb..53852a4bd88b 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1987,6 +1987,11 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		if (entry->fattr->valid & NFS_ATTR_FATTR_V3)
 			entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
 
+		if (entry->fattr->fileid != entry->ino) {
+			entry->fattr->mounted_on_fileid = entry->ino;
+			entry->fattr->valid |= NFS_ATTR_FATTR_MOUNTED_ON_FILEID;
+		}
+
 		/* In fact, a post_op_fh3: */
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(p == NULL))
-- 
2.1.0

