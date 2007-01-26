From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fs/lockd/clntlock.c: add missing newlines to
	dprintk's
Date: Fri, 26 Jan 2007 20:06:01 +0100
Message-ID: <20070126190601.GQ17836@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAWOi-0005nn-Iz
	for nfs@lists.sourceforge.net; Fri, 26 Jan 2007 11:06:05 -0800
Received: from emailhub.stusta.mhn.de ([141.84.69.5]
	helo=mailhub.stusta.mhn.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAWOg-0002c1-7f
	for nfs@lists.sourceforge.net; Fri, 26 Jan 2007 11:06:05 -0800
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

This patch adds missing newlines to dprintk's.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 fs/lockd/clntlock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.20-rc4-mm1/fs/lockd/clntlock.c.old	2007-01-26 19:31:43.000000000 +0100
+++ linux-2.6.20-rc4-mm1/fs/lockd/clntlock.c	2007-01-26 19:32:01.000000000 +0100
@@ -176,7 +176,7 @@
 	lock_kernel();
 	lockd_up(0); /* note: this cannot fail as lockd is already running */
 
-	dprintk("lockd: reclaiming locks for host %s", host->h_name);
+	dprintk("lockd: reclaiming locks for host %s\n", host->h_name);
 
 restart:
 	nsmstate = host->h_nsmstate;
@@ -206,7 +206,7 @@
 
 	host->h_reclaiming = 0;
 	up_write(&host->h_rwsem);
-	dprintk("NLM: done reclaiming locks for host %s", host->h_name);
+	dprintk("NLM: done reclaiming locks for host %s\n", host->h_name);
 
 	/* Now, wake up all processes that sleep on a blocked lock */
 	list_for_each_entry(block, &nlm_blocked, b_list) {


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
