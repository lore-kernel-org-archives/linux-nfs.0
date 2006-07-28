From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 4] knfsd: Move makesock failed warning into
	make_socks.
Date: Fri, 28 Jul 2006 15:09:57 +1000
Message-ID: <1060728050957.503@suse.de>
References: <20060728150606.29533.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6KcU-0003sq-7j
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:42 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6KcU-0002aM-4w
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:42 -0700
To: Andrew Morton <akpm@osdl.org>
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


Thus it is printed for any path that leads to failure (make_socks is
called from two places).

Cc: "J. Bruce Fields" <bfields@fieldses.org>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/svc.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff .prev/fs/lockd/svc.c ./fs/lockd/svc.c
--- .prev/fs/lockd/svc.c	2006-07-28 15:00:55.000000000 +1000
+++ ./fs/lockd/svc.c	2006-07-28 15:01:30.000000000 +1000
@@ -227,15 +227,19 @@ static int make_socks(struct svc_serv *s
 	 * If nlm_udpport or nlm_tcpport were set as module
 	 * options, make those sockets unconditionally
 	 */
+	static int		warned;
 	int err = 0;
 	if (proto == IPPROTO_UDP || nlm_udpport)
 		if (!find_socket(serv, IPPROTO_UDP))
 			err = svc_makesock(serv, IPPROTO_UDP, nlm_udpport);
-	if (err)
-		return err;
-	if (proto == IPPROTO_TCP || nlm_tcpport)
+	if (err == 0 && (proto == IPPROTO_TCP || nlm_tcpport))
 		if (!find_socket(serv, IPPROTO_TCP))
 			err= svc_makesock(serv, IPPROTO_TCP, nlm_tcpport);
+	if (!err)
+		warned = 0;
+	else if (warned++ == 0)
+		printk(KERN_WARNING
+		       "lockd_up: makesock failed, error=%d\n", err);
 	return err;
 }
 
@@ -245,7 +249,6 @@ static int make_socks(struct svc_serv *s
 int
 lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 {
-	static int		warned;
 	struct svc_serv *	serv;
 	int			error = 0;
 
@@ -278,13 +281,8 @@ lockd_up(int proto) /* Maybe add a 'fami
 		goto out;
 	}
 
-	if ((error = make_socks(serv, proto)) < 0) {
-		if (warned++ == 0) 
-			printk(KERN_WARNING
-				"lockd_up: makesock failed, error=%d\n", error);
+	if ((error = make_socks(serv, proto)) < 0)
 		goto destroy_and_out;
-	} 
-	warned = 0;
 
 	/*
 	 * Create the kernel thread and wait for it to start.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
