From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 9] knfsd: knfsd: Remove an unused variable from
	e_show().
Date: Tue, 25 Jul 2006 11:54:32 +1000
Message-ID: <1060725015432.21921@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C8d-0004aE-Qz
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:12 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C8d-0003yD-Pn
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:12 -0700
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


From: Greg Banks <gnb@melbourne.sgi.com>

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |    2 --
 1 file changed, 2 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-07-24 14:33:06.000000000 +1000
+++ ./fs/nfsd/export.c	2006-07-24 14:33:26.000000000 +1000
@@ -1178,7 +1178,6 @@ static int e_show(struct seq_file *m, vo
 {
 	struct cache_head *cp = p;
 	struct svc_export *exp = container_of(cp, struct svc_export, h);
-	svc_client *clp;
 
 	if (p == (void *)1) {
 		seq_puts(m, "# Version 1.1\n");
@@ -1186,7 +1185,6 @@ static int e_show(struct seq_file *m, vo
 		return 0;
 	}
 
-	clp = exp->ex_client;
 	cache_get(&exp->h);
 	if (cache_check(&svc_export_cache, &exp->h, NULL))
 		return 0;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
