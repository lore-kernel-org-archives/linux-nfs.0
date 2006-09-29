From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 8] knfsd: Fix auto-sizing of nfsd request/reply
	buffers
Date: Fri, 29 Sep 2006 13:08:50 +1000
Message-ID: <1060929030850.24050@suse.de>
References: <20060929130518.23919.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT8kF-0007om-65
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:59 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT8kF-00056k-Hm
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:09:00 -0700
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


totalram is measured in pages, not bytes, so PAGE_SHIFT must be used
when trying to find 1/4096 of RAM.

Cc:  "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-09-29 11:44:32.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-09-29 11:57:27.000000000 +1000
@@ -209,7 +209,7 @@ int nfsd_create_serv(void)
 		 * Of course, this is only a default.
 		 */
 		nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
-		i.totalram >>= 12;
+		i.totalram <<= PAGE_SHIFT - 12;
 		while (nfsd_max_blksize > i.totalram &&
 		       nfsd_max_blksize >= 8*1024*2)
 			nfsd_max_blksize /= 2;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
