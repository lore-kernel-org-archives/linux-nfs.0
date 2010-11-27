Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1509 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab0K0SYG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Nov 2010 13:24:06 -0500
Subject: Re: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache
 array" is bad
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Simon Kirby <sim@hostway.ca>
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Bryan Schumaker <bjschuma@netapp.com>, rees@umich.edu
In-Reply-To: <20101127102732.GD12175@hostway.ca>
References: <Pine.LNX.4.64.1011261255260.16655@axis700.grange>
	 <1290794726.4905.8.camel@heimdal.trondhjem.org>
	 <20101127002548.GA20008@hostway.ca>  <20101127102732.GD12175@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 27 Nov 2010 13:24:00 -0500
Message-ID: <1290882240.3415.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-11-27 at 02:27 -0800, Simon Kirby wrote:
> Ok, so I tracked them down, and they didn't seem to be particularly
> unusual, so I tried a not-particularly-unusual thing that I figured might
> work, and reproduced it:
> 
> server: echo test > a
> client: ls -l
> server: echo test > b ; mv b a
> client: ls -l
> 
> That's it.  The kernel (2.6.37-rc3), on the final "ls -l", says:
> 
> [12814.611197] NFS: server 10.10.52.228 error: fileid changed
> [12814.611200] fsid 0:3f: expected fileid 0x122efbf1, got 0x122efc15
> 
> "ls -li" shows the inode updated, so maybe this isn't even a bug?

Ah! I think I see it now, and yes it is a bug...

Does the following patch fix it?

Cheers
  Trond
-------------------------------------------------------------------------------------
NFS: Fix a readdirplus bug
From: Trond Myklebust <Trond.Myklebust@netapp.com>

When comparing filehandles in the helper nfs_same_file(), we should not be
using 'strncmp()': filehandles are not null terminated strings.

Instead, we should just use the existing helper nfs_compare_fh().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8ea4a41..f0a384e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -395,13 +395,9 @@ int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, struct x
 static
 int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
 {
-	struct nfs_inode *node;
 	if (dentry->d_inode == NULL)
 		goto different;
-	node = NFS_I(dentry->d_inode);
-	if (node->fh.size != entry->fh->size)
-		goto different;
-	if (strncmp(node->fh.data, entry->fh->data, node->fh.size) != 0)
+	if (nfs_compare_fh(entry->fh, NFS_FH(dentry->d_inode)) != 0)
 		goto different;
 	return 1;
 different:


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

