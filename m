Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:51380 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaDMPYU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 11:24:20 -0400
Received: by mail-ig0-f176.google.com with SMTP id uy17so2524429igb.15
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 08:24:19 -0700 (PDT)
Message-ID: <1397402659.6306.5.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: add FATTR4_WORD1_MODE flags for
 cache_consistency_bitmask
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Date: Sun, 13 Apr 2014 11:24:19 -0400
In-Reply-To: <534AA4FD.3060202@gmail.com>
References: <534A8CEF.6000609@gmail.com>
	 <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>
	 <534AA4FD.3060202@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2014-04-13 at 22:53 +0800, Kinglong Mee wrote:
> 
> 于 2014/4/13 22:28, Trond Myklebust 写道:
> > 
> > On Apr 13, 2014, at 9:11, Kinglong Mee <kinglongmee@gmail.com> wrote:
> > 
> >> After writing data at NFS client, file's access mode is inconsistent
> >> with server.
> >> Because WRITE proceduce changes the S_ISUID and S_ISGID bits,
> >> but client don't get it.
> >>
> >> #touch hello; chmod 06777 hello; stat hello;
> >>   File: ‘hello’
> >>   Size: 0               Blocks: 0          IO Block: 262144 regular
> >> empty file
> >> Device: 24h/36d Inode: 786434      Links: 1
> >> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> >> Context: system_u:object_r:nfs_t:s0
> >> Access: 2014-04-13 21:00:44.996908708 +0800
> >> Modify: 2014-04-13 21:00:44.996908708 +0800
> >> Change: 2014-04-13 21:00:45.033908705 +0800
> >> Birth: -
> >>
> >> #echo 12324 > hello; stat hello; stat /nfstest/hello
> >>   File: ‘hello’
> >>   Size: 6               Blocks: 0          IO Block: 262144 regular file
> >> Device: 24h/36d Inode: 786434      Links: 1
> >> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> >>          ^^^^^ it should be 0777
> >> Context: system_u:object_r:nfs_t:s0
> >> Access: 2014-04-13 21:00:44.996908708 +0800
> >> Modify: 2014-04-13 21:00:45.061908703 +0800
> >> Change: 2014-04-13 21:00:45.061908703 +0800
> >> Birth: -
> >>   File: ‘/nfstest/hello’
> >>   Size: 6               Blocks: 8          IO Block: 4096   regular file
> >> Device: 803h/2051d      Inode: 786434      Links: 1
> >> Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> >>          ^^^^^ bits on the server
> >> Context: system_u:object_r:default_t:s0
> >> Access: 2014-04-13 21:00:44.996908708 +0800
> >> Modify: 2014-04-13 21:00:45.061908703 +0800
> >> Change: 2014-04-13 21:00:45.061908703 +0800
> >> Birth: -
> >>
<snip>
> > 
> > Instead of requesting a new attribute on each and every operation just in order to deal with an extremely rare corner case, is there any reason why we can’t just do this by checking should_remove_suid(), clearing the mode bits ourselves, and then marking the attributes for revalidation?
> 
<snip>
> IMO, client shoulds get all metadatas from server, so, adds the flag.
> I think should_remove_suid() should be called by nfsd, not NFS client

I agree with 50% of that statement. Please see below.

8<---------------------------------------------------------------------
>From a7b05fc5fcb433e8cfca577c9275f2012b523ee8 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 13 Apr 2014 11:11:31 -0400
Subject: [PATCH] NFS: Don't ignore suid/sgid bit changes after a successful
 write

If we suspect that the server may have cleared the suid/sgid bit,
then mark the inode for revalidation.

Reported-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9a3b6a4cd6b9..80b03e064a09 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1401,9 +1401,16 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		}
 	}
 #endif
-	if (task->tk_status < 0)
+	if (task->tk_status < 0) {
 		nfs_set_pgio_error(data->header, task->tk_status, argp->offset);
-	else if (resp->count < argp->count) {
+		return;
+	}
+
+	/* Deal with the suid/sgid bit corner case */
+	if (should_remove_suid(argp->context->dentry))
+		nfs_mark_for_revalidate(inode);
+
+	if (resp->count < argp->count) {
 		static unsigned long    complain;
 
 		/* This a short write! */
-- 
1.9.0


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


