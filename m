From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Let's get rid of those annoying "VFS is out of sync with lock
	manager" messages (includes proposed patch)
Date: Thu, 7 Dec 2006 22:08:16 +0100
Message-ID: <200612072208.16350.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Jesper Juhl <jesper.juhl@gmail.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsQRg-0003GH-EN
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 13:06:20 -0800
Received: from nf-out-0910.google.com ([64.233.182.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GsQRh-0001g7-EG
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 13:06:21 -0800
Received: by nf-out-0910.google.com with SMTP id c31so1733186nfb
	for <nfs@lists.sourceforge.net>; Thu, 07 Dec 2006 13:06:20 -0800 (PST)
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

Hi,

A while back I reported that I had a bunch of servers that started 
complaining about VFS being out of sync with lock manager - 
the thread title was 
  "[NFS] 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock manager!"
During the course of that thread Neil Brown proposed a patch to resolve the
issue with the following description:

"
 - do_vfs_lock is only called when the filesystem was mounted with
   -o nolock  EXCEPT
 - If a lock request to the server in interrupted (when mounted with
    -o intr) then do_vfs_lock is called to try to get the lock
   locally.  Normally equivalent code will be called inside
   fs/lockd/clntproc.c when the server replies that the lock has been
   gained.  In the case of an interrupt though this doesn't happen
   but the lock may still have happened on the server.  So we record
   locally that the lock was gained, to ensure that it gets unlocked
   when the process exits.

As you don't have '-o nolocks' you must be hitting the second case.
The lock call to the server returns -EINTR or -ERESTARTSYS and
do_vfs_lock is called just-in-case.
As this is a just-in-case call, it is quite possible that the lock is
held by some other process, so getting an error is entirely possible.
So printing the message in this case seems wrong.

On the other hand, printing the message in any other case seems wrong
too, as server locking is not being used, so there is nothing to get
out of sync with.

As a further complication, I don't think that in the just-in-case
situation that it should risk waiting for the lock.
Now maybe we can be sure there is a pending signal which will break
out of any wait (though I'm worried about -ERESTARTSYS - that doesn't
imply a signal does it?), but I would feel more comfortable if
FL_SLEEP were turned off in that path.
"

To which Trond Myklebust replied:

"
Could we instead replace it with a dprintk() that returns the value of
"res"? That will keep it useful for debugging purposes.
"

So I took Neils patch, made the change Trond suggested and the result is 
below.

Comments?  Ok to merge?  


Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 fs/nfs/file.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index cc93865..22572af 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -428,8 +428,8 @@ static int do_vfs_lock(struct file *file
 			BUG();
 	}
 	if (res < 0)
-		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n",
-				__FUNCTION__);
+		dprintk("%s: VFS is out of sync with lock manager (res = %d)!\n",
+				__FUNCTION__, res);
 	return res;
 }
 
@@ -479,10 +479,13 @@ static int do_setlk(struct file *filp, i
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
