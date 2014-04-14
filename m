Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36965 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbaDNPAk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 11:00:40 -0400
Received: by mail-ig0-f173.google.com with SMTP id hl10so3460067igb.6
        for <linux-nfs@vger.kernel.org>; Mon, 14 Apr 2014 08:00:39 -0700 (PDT)
Message-ID: <1397487639.7280.4.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: add FATTR4_WORD1_MODE flags for
 cache_consistency_bitmask
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, Dr Fields James Bruce <bfields@fieldses.org>
Date: Mon, 14 Apr 2014 11:00:39 -0400
In-Reply-To: <534BE338.2030001@gmail.com>
References: <534A8CEF.6000609@gmail.com>
		 <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>
		 <534AA4FD.3060202@gmail.com> <1397402659.6306.5.camel@leira.trondhjem.org>
	 <534BDBB6.5030306@gmail.com>
	 <4B0A3D7E-5DD0-47A2-B1C8-A2F64E37D781@primarydata.com>
	 <534BE338.2030001@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-04-14 at 21:31 +0800, Kinglong Mee wrote:
> 
> 于 2014/4/14 21:12, Trond Myklebust 写道:
> >
> > On Apr 14, 2014, at 8:59, Kinglong Mee <kinglongmee@gmail.com> wrote:
> >
> >>
> >>
> >> 于 2014/4/13 23:24, Trond Myklebust 写道:
> >>> On Sun, 2014-04-13 at 22:53 +0800, Kinglong Mee wrote:
> >>>>
> >>>> 于 2014/4/13 22:28, Trond Myklebust 写道:
> >>>>>
> >>>>> On Apr 13, 2014, at 9:11, Kinglong Mee <kinglongmee@gmail.com> wrote:
> >>>>>
> >>>>>> After writing data at NFS client, file's access mode is inconsistent
> >>>>>> with server.
> >>>>>> Because WRITE proceduce changes the S_ISUID and S_ISGID bits,
> >>>>>> but client don't get it.
> >>>>>>
> >>>>>> #touch hello; chmod 06777 hello; stat hello;
> >>>>>>    File: ‘hello’
> >>>>>>    Size: 0               Blocks: 0          IO Block: 262144 regular
> >>>>>> empty file
> >>>>>> Device: 24h/36d Inode: 786434      Links: 1
> >>>>>> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> >>>>>> Context: system_u:object_r:nfs_t:s0
> >>>>>> Access: 2014-04-13 21:00:44.996908708 +0800
> >>>>>> Modify: 2014-04-13 21:00:44.996908708 +0800
> >>>>>> Change: 2014-04-13 21:00:45.033908705 +0800
> >>>>>> Birth: -
> >>>>>>
> >>>>>> #echo 12324 > hello; stat hello; stat /nfstest/hello
> >>>>>>    File: ‘hello’
> >>>>>>    Size: 6               Blocks: 0          IO Block: 262144 regular file
> >>>>>> Device: 24h/36d Inode: 786434      Links: 1
> >>>>>> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> >>>>>>           ^^^^^ it should be 0777
> >>>>>> Context: system_u:object_r:nfs_t:s0
> >>>>>> Access: 2014-04-13 21:00:44.996908708 +0800
> >>>>>> Modify: 2014-04-13 21:00:45.061908703 +0800
> >>>>>> Change: 2014-04-13 21:00:45.061908703 +0800
> >>>>>> Birth: -
> >>>>>>    File: ‘/nfstest/hello’
> >>>>>>    Size: 6               Blocks: 8          IO Block: 4096   regular file
> >>>>>> Device: 803h/2051d      Inode: 786434      Links: 1
> >>>>>> Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> >>>>>>           ^^^^^ bits on the server
> >>>>>> Context: system_u:object_r:default_t:s0
> >>>>>> Access: 2014-04-13 21:00:44.996908708 +0800
> >>>>>> Modify: 2014-04-13 21:00:45.061908703 +0800
> >>>>>> Change: 2014-04-13 21:00:45.061908703 +0800
> >>>>>> Birth: -
> >>>>>>
> >>> <snip>
> >>>>>
> >>>>> Instead of requesting a new attribute on each and every operation just in order to deal with an extremely rare corner case, is there any reason why we can’t just do this by checking should_remove_suid(), clearing the mode bits ourselves, and then marking the attributes for revalidation?
> >>>>
> >>> <snip>
> >>>> IMO, client shoulds get all metadatas from server, so, adds the flag.
> >>>> I think should_remove_suid() should be called by nfsd, not NFS client
> >>>
> >>> I agree with 50% of that statement. Please see below.
> >>>
> >>> 8<---------------------------------------------------------------------
> >>>>  From a7b05fc5fcb433e8cfca577c9275f2012b523ee8 Mon Sep 17 00:00:00 2001
> >>> From: Trond Myklebust <trond.myklebust@primarydata.com>
> >>> Date: Sun, 13 Apr 2014 11:11:31 -0400
> >>> Subject: [PATCH] NFS: Don't ignore suid/sgid bit changes after a successful
> >>>   write
> >>>
> >>> If we suspect that the server may have cleared the suid/sgid bit,
> >>> then mark the inode for revalidation.
> >>
> >> When testing with this patch, should_remove_suid() always return false
> >> at client, but return true at NFS server.
> >>
> >> So that, NFS server clears the suid/sgid bit, but client also remains.
> >
> > Are you running the test as root? The only explanation I can see for should_remove_suid() failing is if the ‘CAP_FSETID’ capability is set.
> 
> I test it with non-root user, should_remove_suid() also return 0.

OK. Let's make a version that ignores the capabilities, and just tests
the SUID/SGID bits.
8<--------------------------------------------------------------------
>From 2e068b62316b2fa5738a8b730bcb5f2f8e7cbdb1 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 13 Apr 2014 11:11:31 -0400
Subject: [PATCH v2] NFS: Don't ignore suid/sgid bit changes after a successful
 write

If we suspect that the server may have cleared the suid/sgid bit,
then mark the inode for revalidation.

Reported-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 35 +++++++++++++++++++++++++++++++++--
 1 file changed, 33 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9a3b6a4cd6b9..cd7c651f9b84 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1353,6 +1353,30 @@ static const struct rpc_call_ops nfs_write_common_ops = {
 	.rpc_release = nfs_writeback_release_common,
 };
 
+/*
+ * Special version of should_remove_suid() that ignores capabilities.
+ */
+static int nfs_should_remove_suid(const struct inode *inode)
+{
+	umode_t mode = inode->i_mode;
+	int kill = 0;
+
+	/* suid always must be killed */
+	if (unlikely(mode & S_ISUID))
+		kill = ATTR_KILL_SUID;
+
+	/*
+	 * sgid without any exec bits is just a mandatory locking mark; leave
+	 * it alone.  If some exec bits are set, it's a real sgid; kill it.
+	 */
+	if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
+		kill |= ATTR_KILL_SGID;
+
+	if (unlikely(kill && S_ISREG(mode)))
+		return kill;
+
+	return 0;
+}
 
 /*
  * This function is called when the WRITE call is complete.
@@ -1401,9 +1425,16 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
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
+	if (nfs_should_remove_suid(inode))
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


