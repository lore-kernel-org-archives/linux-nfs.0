From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 12 Dec 2005 18:51:50 -0500
Message-ID: <1134431510.8028.26.camel@lade.trondhjem.org>
References: <4382252E.4000602@google.com>
	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>
	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com>
	 <1132614431.8011.14.camel@lade.trondhjem.org> <438B4983.3030809@google.com>
	 <1133203961.27574.66.camel@lade.trondhjem.org>
	 <4394AB2E.1030809@google.com>  <439DC809.3020502@google.com>
	 <1134415137.7877.10.camel@lade.trondhjem.org> <439DDE7D.3050904@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KQJbZn3N/q4Jknz2QG3p"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ElxSm-0002yF-Ik
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 15:52:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ElxSl-0003x3-8t
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 15:52:12 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <439DDE7D.3050904@google.com>
Sender: nfs-admin@lists.sourceforge.net
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


--=-KQJbZn3N/q4Jknz2QG3p
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2005-12-12 at 12:33 -0800, Vince Busam wrote:
> Trond Myklebust wrote:
> > 
> > Could you send us the contents of rpc_close_pipes() and
> > rpc_pipe_release()?
> > 

Hmm.... Looks correct. The only potential races I can see should be
fixed by the following patch. Can you apply and then try again?

Cheers,
  Trond


--=-KQJbZn3N/q4Jknz2QG3p
Content-Disposition: inline; filename=linux-2.6.15-37-fix_rpc_pipefs_race.dif
Content-Type: text/plain; name=linux-2.6.15-37-fix_rpc_pipefs_race.dif; charset=utf-8
Content-Transfer-Encoding: 7bit

SUNRPC: Fix a potential race in rpc_pipefs.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpc_pipe.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index c76ea22..511647e 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -70,8 +70,11 @@ rpc_timeout_upcall_queue(void *data)
 	struct inode *inode = &rpci->vfs_inode;
 
 	down(&inode->i_sem);
+	if (rpci->ops == NULL)
+		goto out;
 	if (rpci->nreaders == 0 && !list_empty(&rpci->pipe))
 		__rpc_purge_upcall(inode, -ETIMEDOUT);
+out:
 	up(&inode->i_sem);
 }
 
@@ -113,8 +116,6 @@ rpc_close_pipes(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 
-	cancel_delayed_work(&rpci->queue_timeout);
-	flush_scheduled_work();
 	down(&inode->i_sem);
 	if (rpci->ops != NULL) {
 		rpci->nreaders = 0;
@@ -127,6 +128,8 @@ rpc_close_pipes(struct inode *inode)
 	}
 	rpc_inode_setowner(inode, NULL);
 	up(&inode->i_sem);
+	cancel_delayed_work(&rpci->queue_timeout);
+	flush_scheduled_work();
 }
 
 static struct inode *
@@ -166,7 +169,7 @@ rpc_pipe_open(struct inode *inode, struc
 static int
 rpc_pipe_release(struct inode *inode, struct file *filp)
 {
-	struct rpc_inode *rpci = RPC_I(filp->f_dentry->d_inode);
+	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_msg *msg;
 
 	down(&inode->i_sem);

--=-KQJbZn3N/q4Jknz2QG3p--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
