From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/14] locks: always unlock on close
Date: Sat,  3 Feb 2007 00:33:57 -0500
Message-ID: <43081.9762325429$1170480875@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDXR-0001HT-AV
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:15 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDDXR-0001BY-Un
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:15 -0800
In-Reply-To: 11704806552464-git-send-email-
References: 11704806552464-git-send-email-
Message-Id: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Currently locks_remove_posix has a shortcut which returns without doing
anything if it doesn't see anything on the inode's lock list.

That may be the wrong thing to do if a filesystem (such as a network or cluster
filesystem) wants to bookkeep locks on its own.

A filesystem should still be able to keep track of locally held locks (such as
all the locks held by one local process), but the occasional kmalloc() failure,
for example, could get the two sets of data structures out of sync, and it
seems best to allow the filesystem to be authoritative.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/locks.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 52a8100..4390a95 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1917,14 +1917,6 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 {
 	struct file_lock lock;
 
-	/*
-	 * If there are no locks held on this file, we don't need to call
-	 * posix_lock_file().  Another process could be setting a lock on this
-	 * file at the same time, but we wouldn't remove that lock anyway.
-	 */
-	if (!filp->f_path.dentry->d_inode->i_flock)
-		return;
-
 	lock.fl_type = F_UNLCK;
 	lock.fl_flags = FL_POSIX | FL_CLOSE;
 	lock.fl_start = 0;
-- 
1.5.0.rc1.g72fe


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
