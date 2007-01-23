From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 5] knfsd: Fix setting of ACL server versions.
Date: Tue, 23 Jan 2007 11:22:13 +1100
Message-ID: <1070123002213.27830@suse.de>
References: <20070123111558.27683.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H99Qr-0007RA-Gr
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:38 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H99Qs-0002Ci-Qq
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:39 -0800
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


Due to silly typos, if the nfs versions are explicitly set,
no NFSACL versions get enabled.

Also improve an error message that would have made this bug
a little easier to find.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |    8 ++++----
 ./net/sunrpc/svc.c |    3 ++-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2007-01-23 11:13:46.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2007-01-23 11:14:49.000000000 +1100
@@ -72,7 +72,7 @@ static struct svc_program	nfsd_acl_progr
 	.pg_prog		= NFS_ACL_PROGRAM,
 	.pg_nvers		= NFSD_ACL_NRVERS,
 	.pg_vers		= nfsd_acl_versions,
-	.pg_name		= "nfsd",
+	.pg_name		= "nfsacl",
 	.pg_class		= "nfsd",
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
@@ -118,16 +118,16 @@ int nfsd_vers(int vers, enum vers_op cha
 	switch(change) {
 	case NFSD_SET:
 		nfsd_versions[vers] = nfsd_version[vers];
-		break;
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 		if (vers < NFSD_ACL_NRVERS)
-			nfsd_acl_version[vers] = nfsd_acl_version[vers];
+			nfsd_acl_versions[vers] = nfsd_acl_version[vers];
 #endif
+		break;
 	case NFSD_CLEAR:
 		nfsd_versions[vers] = NULL;
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 		if (vers < NFSD_ACL_NRVERS)
-			nfsd_acl_version[vers] = NULL;
+			nfsd_acl_versions[vers] = NULL;
 #endif
 		break;
 	case NFSD_TEST:

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2007-01-23 11:13:46.000000000 +1100
+++ ./net/sunrpc/svc.c	2007-01-23 11:14:49.000000000 +1100
@@ -910,7 +910,8 @@ err_bad_prog:
 
 err_bad_vers:
 #ifdef RPC_PARANOIA
-	printk("svc: unknown version (%d)\n", vers);
+	printk("svc: unknown version (%d for prog %d, %s)\n",
+	       vers, prog, progp->pg_name);
 #endif
 	serv->sv_stats->rpcbadfmt++;
 	svc_putnl(resv, RPC_PROG_MISMATCH);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
