From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 12:07:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041015100703.GA27307@suse.de>
References: <20041015095840.GA22992@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIP40-000750-CP
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 03:11:56 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CIP3v-00012Q-Ou
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 03:11:56 -0700
To: nfs@lists.sourceforge.net, akpm@osdl.org
In-Reply-To: <20041015095840.GA22992@suse.de>
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


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 15, 2004 at 11:58:40AM +0200, Olaf Kirch wrote:
> I don't know why this change was made. The patch below simply reverts
> these two hunks; maybe there's a better solution involving LOCK_USE_CLNT
> the way it's used for F_GETLK at the moment.

I forgot to add the patch. Below there are two possible fixes.

 fix1: just revert the changes

 fix2: use LOCK_USE_CLNT for all locking operations if mounted nolock.

The second one is probably better...

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfs-nolock-fix1

Index: linux-2.6.9-rc4/fs/locks.c
===================================================================
--- linux-2.6.9-rc4.orig/fs/locks.c
+++ linux-2.6.9-rc4/fs/locks.c
@@ -1534,7 +1534,8 @@ int fcntl_setlk(struct file *filp, unsig
 
 	if (filp->f_op && filp->f_op->lock != NULL) {
 		error = filp->f_op->lock(filp, cmd, file_lock);
-		goto out;
+		if (error < 0)
+			goto out;
 	}
 
 	for (;;) {
@@ -1668,7 +1669,8 @@ int fcntl_setlk64(struct file *filp, uns
 
 	if (filp->f_op && filp->f_op->lock != NULL) {
 		error = filp->f_op->lock(filp, cmd, file_lock);
-		goto out;
+		if (error < 0)
+			goto out;
 	}
 
 	for (;;) {
@@ -1720,7 +1722,7 @@ void locks_remove_posix(struct file *fil
 
 	if (filp->f_op && filp->f_op->lock != NULL) {
 		filp->f_op->lock(filp, F_SETLK, &lock);
-		goto out;
+		/* Ignore any error -- we must remove the locks anyway */
 	}
 
 	/* Can't use posix_lock_file here; we need to remove it no matter

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfs-nolock-fix2


A previous change broke locking on NFS file systems mounted -o nolock.
This patch fixes the problem by making all NFS lock calls return
LOCK_USE_CLNT in this case, and treating it the way we did previously.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.9-rc4/fs/locks.c
===================================================================
--- linux-2.6.9-rc4.orig/fs/locks.c
+++ linux-2.6.9-rc4/fs/locks.c
@@ -1534,7 +1534,8 @@ int fcntl_setlk(struct file *filp, unsig
 
 	if (filp->f_op && filp->f_op->lock != NULL) {
 		error = filp->f_op->lock(filp, cmd, file_lock);
-		goto out;
+		if (error != LOCK_USE_CLNT)
+			goto out;
 	}
 
 	for (;;) {
@@ -1668,7 +1669,8 @@ int fcntl_setlk64(struct file *filp, uns
 
 	if (filp->f_op && filp->f_op->lock != NULL) {
 		error = filp->f_op->lock(filp, cmd, file_lock);
-		goto out;
+		if (error != LOCK_USE_CLNT)
+			goto out;
 	}
 
 	for (;;) {
@@ -1719,8 +1721,9 @@ void locks_remove_posix(struct file *fil
 	lock.fl_lmops = NULL;
 
 	if (filp->f_op && filp->f_op->lock != NULL) {
-		filp->f_op->lock(filp, F_SETLK, &lock);
-		goto out;
+		error = filp->f_op->lock(filp, F_SETLK, &lock);
+		if (error != LOCK_USE_CLNT)
+			goto out;
 	}
 
 	/* Can't use posix_lock_file here; we need to remove it no matter
Index: linux-2.6.9-rc4/fs/nfs/file.c
===================================================================
--- linux-2.6.9-rc4.orig/fs/nfs/file.c
+++ linux-2.6.9-rc4/fs/nfs/file.c
@@ -397,11 +397,9 @@ nfs_lock(struct file *filp, int cmd, str
 		return -ENOLCK;
 
 	if (NFS_PROTO(inode)->version != 4) {
-		/* Fake OK code if mounted without NLM support */
+		/* If mounted NONLM, tell VFS to use local locking only. */
 		if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) {
-			if (IS_GETLK(cmd))
-				return LOCK_USE_CLNT;
-			return 0;
+			return LOCK_USE_CLNT;
 		}
 	}
 

--YZ5djTAD1cGYuMQK--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
