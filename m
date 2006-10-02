From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2 of 3] nfsd4: fslocs: fix compile in
	non-CONFIG_NFSD_V4 case
Date: Mon, 2 Oct 2006 14:26:03 -0400
Message-ID: <20061002182603.GD8084@fieldses.org>
References: <20060929130518.23919.patches@notabene>
	<1060929030913.24108@suse.de>
	<20060928234540.fd74f1e1.akpm@osdl.org>
	<20061002182327.GB8084@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUSUQ-0006RD-9x
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 11:26:06 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GUSUQ-0008Q2-SQ
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 11:26:07 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061002182327.GB8084@fieldses.org>
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


Fix fsloc_parse in the non-CONFIG_NFSD_V4 case, to make it inline, to
make it consistent with the definition in the CONFIG_NFSD_V4 case, and
to include parameter names.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 71f3655..ee7b03a 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -463,7 +463,7 @@ out_free_all:
 }
 
 #else /* CONFIG_NFSD_V4 */
-static int fsloc_parse(char **, char *, struct svc_export *) { return 0; }
+static inline int fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc) { return 0; }
 #endif
 
 static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
-- 
1.4.2.g55c3


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
