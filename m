From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with
	lock	manager!
Date: Mon, 29 Jan 2007 16:08:44 +1100
Message-ID: <17853.33116.113629.65031@notabene.brown>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<17636.4462.975774.528003@cse.unsw.edu.au>
	<9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
	<17641.10665.116168.867041@cse.unsw.edu.au>
	<1156190098.6158.109.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jesper Juhl <jesper.juhl@gmail.com>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBOlW-0004pv-Kq
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 21:09:14 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBOlX-0002lT-6q
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 21:09:16 -0800
In-Reply-To: message from Trond Myklebust on Monday August 21
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

On Monday August 21, trond.myklebust@fys.uio.no wrote:
> 
> Could we instead replace it with a dprintk() that returns the value of
> "res"? That will keep it useful for debugging purposes.

(only 5 months later...)

Sure, how about this?

Thanks,
NeilBrown


Remove warning: VFS is out of sync with lock manager.

But keep it as a dprintk

The message can be generated in a quite normal situation:
 If a 'lock' request is interrupted, then the lock client needs to
  record that the server has the lock, incase it does.
 When we come the unlock, the server might say it doesn't, even
  though we think it does (or might) and this generates the message.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfs/file.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff .prev/fs/nfs/file.c ./fs/nfs/file.c
--- .prev/fs/nfs/file.c	2007-01-29 16:04:09.000000000 +1100
+++ ./fs/nfs/file.c	2007-01-29 16:04:45.000000000 +1100
@@ -434,8 +434,9 @@ static int do_vfs_lock(struct file *file
 			BUG();
 	}
 	if (res < 0)
-		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n",
-				__FUNCTION__);
+		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
+			" - error %d!\n",
+				__FUNCTION__, res);
 	return res;
 }
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
