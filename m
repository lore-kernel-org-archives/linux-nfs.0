From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] locks: kill redundant local variable
Date: Wed, 11 Jul 2007 09:14:05 -0400
Message-ID: <20070711131405.14746.99176.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8c1F-00074E-IW
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 06:14:13 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8c1J-0005nI-0d
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 06:14:17 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: \"J. Bruce Fields\" <bfields@fieldses.org>

There's no need for another variable local to this loop; we can use the
variable (of the same name!) already declared at the top of the function,
and not used till later (at which point it's initialized, so this is safe).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/locks.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 431a8b8..2e8f21b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -823,7 +823,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	lock_kernel();
 	if (request->fl_type != F_UNLCK) {
 		for_each_lock(inode, before) {
-			struct file_lock *fl = *before;
+			fl = *before;
 			if (!IS_POSIX(fl))
 				continue;
 			if (!posix_locks_conflict(request, fl))

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
