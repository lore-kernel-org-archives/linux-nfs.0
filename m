From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/8] Fix memory leak on error path of
	limit_krb5_enctypes()
Date: Fri, 30 Mar 2007 18:32:08 -0400
Message-ID: <20070330223208.28802.55727.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdg-0000KG-E5
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:08 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPdg-0006EF-VA
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:10 -0700
In-Reply-To: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Return credential on error path of limit_krb5_enctypes()

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index f1682b8..a0ee110 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -298,6 +298,7 @@ limit_krb5_enctypes(struct rpc_gss_sec *
 	if (maj_stat != GSS_S_COMPLETE) {
 		pgsserr("gss_set_allowable_enctypes",
 			maj_stat, min_stat, &krb5oid);
+		gss_release_cred(&min_stat, &credh);
 		return -1;
 	}
 	sec->cred = credh;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
