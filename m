From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 17:11:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097853073.5558.17.camel@lade.trondhjem.org>
References: <20041015095840.GA22992@suse.de>
	 <20041015100703.GA27307@suse.de>
	 <1097851608.5558.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CITkf-0001y3-2c
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:12:17 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CITjt-0007eU-2C
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:12:16 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <1097851608.5558.15.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  NFS: when we mount with the "nolock" flag we need to use local locking.

  Signed-off-by: Trond Myklebust <trond.myklebust@fys.uio.no>
---

 file.c |   43 +++++++++++++++++++++++--------------------
 1 files changed, 23 insertions(+), 20 deletions(-)

Index: linux-2.6.9-rc4-up/fs/nfs/file.c
===================================================================
--- linux-2.6.9-rc4-up.orig/fs/nfs/file.c	2004-10-15 12:03:43.000000000 +0200
+++ linux-2.6.9-rc4-up/fs/nfs/file.c	2004-10-15 16:56:59.804503229 +0200
@@ -298,7 +298,11 @@ static int do_getlk(struct file *filp, i
 	int status;
 
 	lock_kernel();
-	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+	/* Use local locking if mounted with "-onolock" */
+	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
+		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+	else
+		status = posix_test_lock(filp, fl);
 	unlock_kernel();
 	return status;
 }
@@ -325,7 +329,11 @@ static int do_unlk(struct file *filp, in
 	 * 	still need to complete the unlock.
 	 */
 	lock_kernel();
-	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+	/* Use local locking if mounted with "-onolock" */
+	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
+		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+	else
+		status = posix_lock_file_wait(filp, fl);
 	rpc_clnt_sigunmask(NFS_CLIENT(inode), &oldset);
 	return status;
 }
@@ -351,15 +359,19 @@ static int do_setlk(struct file *filp, i
 		return status;
 
 	lock_kernel();
-	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
-	/* If we were signalled we still need to ensure that
-	 * we clean up any state on the server. We therefore
-	 * record the lock call as having succeeded in order to
-	 * ensure that locks_remove_posix() cleans it out when
-	 * the process exits.
-	 */
-	if (status == -EINTR || status == -ERESTARTSYS)
-		posix_lock_file(filp, fl);
+	/* Use local locking if mounted with "-onolock" */
+	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)) {
+		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+		/* If we were signalled we still need to ensure that
+		 * we clean up any state on the server. We therefore
+		 * record the lock call as having succeeded in order to
+		 * ensure that locks_remove_posix() cleans it out when
+		 * the process exits.
+		 */
+		if (status == -EINTR || status == -ERESTARTSYS)
+			posix_lock_file(filp, fl);
+	} else
+		status = posix_lock_file_wait(filp, fl);
 	unlock_kernel();
 	if (status < 0)
 		return status;
@@ -396,15 +408,6 @@ nfs_lock(struct file *filp, int cmd, str
 	if ((inode->i_mode & (S_ISGID | S_IXGRP)) == S_ISGID)
 		return -ENOLCK;
 
-	if (NFS_PROTO(inode)->version != 4) {
-		/* Fake OK code if mounted without NLM support */
-		if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) {
-			if (IS_GETLK(cmd))
-				return LOCK_USE_CLNT;
-			return 0;
-		}
-	}
-
 	/*
 	 * No BSD flocks over NFS allowed.
 	 * Note: we could try to fake a POSIX lock request here by




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
