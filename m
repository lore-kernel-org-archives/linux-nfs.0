From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] VFS: turn off FL_SLEEP when calling do_vfs_lock()
	just in case and get rid of "VFS is out of sync with lock
	manager" messages
Date: Fri, 15 Dec 2006 14:50:52 +0100
Message-ID: <200612151450.53029.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvDSv-0002pH-NR
	for nfs@lists.sourceforge.net; Fri, 15 Dec 2006 05:51:09 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GvDSw-0004A5-I2
	for nfs@lists.sourceforge.net; Fri, 15 Dec 2006 05:51:11 -0800
Received: by ug-out-1314.google.com with SMTP id z38so826085ugc
	for <nfs@lists.sourceforge.net>; Fri, 15 Dec 2006 05:51:07 -0800 (PST)
To: linux-kernel@vger.kernel.org
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


Convert "VFS is out of sync with lock manager!" printk() in
do_vfs_lock() to dprintk() since the message is useless in normal use
but could possibly be useful as a debugging aid.
Also turn off FL_SLEEP when calling do_vfs_lock() just in case, after
getting -EINTR or -ERESTARTSYS.

Patch has been tested on a production webserver and works just fine.


Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 fs/nfs/file.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 0dd6be3..4cf4166 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -434,8 +434,8 @@ static int do_vfs_lock(struct file *file
 			BUG();
 	}
 	if (res < 0)
-		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n",
-				__FUNCTION__);
+		dprintk("%s: VFS is out of sync with lock manager (res = %d)!\n",
+				__FUNCTION__, res);
 	return res;
 }
 
@@ -485,10 +485,13 @@ static int do_setlk(struct file *filp, i
 		 * we clean up any state on the server. We therefore
 		 * record the lock call as having succeeded in order to
 		 * ensure that locks_remove_posix() cleans it out when
-		 * the process exits.
+		 * the process exits. Make sure not to sleep if
+		 * someone else holds the lock.
 		 */
-		if (status == -EINTR || status == -ERESTARTSYS)
+		if (status == -EINTR || status == -ERESTARTSYS) {
+			fl->fl_flags &= ~FL_SLEEP;
 			do_vfs_lock(filp, fl);
+		}
 	} else
 		status = do_vfs_lock(filp, fl);
 	unlock_kernel();



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
