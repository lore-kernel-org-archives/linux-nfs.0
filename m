From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 8 - Fix problems when releasing cache item.
Date: Wed, 16 Oct 2002 16:03:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH1-0000J6-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHB-0002mj-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 16 Oct 2002 16:03:17 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

When releasing a cache item we always release anything
that is part of the key, but we ONLY release the content
is if it is valid.  i.e. if CACHE_VALID but not CACHE_NEGATIVE.




 ----------- Diffstat output ------------
 ./fs/nfsd/export.c          |    3 ++-
 ./net/sunrpc/svcauth_unix.c |    4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

--- ./fs/nfsd/export.c	2002/10/16 04:46:50	1.1
+++ ./fs/nfsd/export.c	2002/10/16 04:46:52	1.2
@@ -70,7 +70,8 @@ void expkey_put(struct cache_head *item,
 {
 	if (cache_put(item, cd)) {
 		struct svc_expkey *key = container_of(item, struct svc_expkey, h);
-		if (key->ek_export)
+		if (test_bit(CACHE_VALID, &item->flags) &&
+		    !test_bit(CACHE_NEGATIVE, &item->flags))
 			exp_put(key->ek_export);
 		auth_domain_put(key->ek_client);
 		kfree(key);
--- ./net/sunrpc/svcauth_unix.c	2002/10/16 04:46:50	1.1
+++ ./net/sunrpc/svcauth_unix.c	2002/10/16 04:46:52	1.2
@@ -90,7 +90,9 @@ void ip_map_put(struct cache_head *item,
 {
 	struct ip_map *im = container_of(item, struct ip_map,h);
 	if (cache_put(item, cd)) {
-		auth_domain_put(&im->m_client->h);
+		if (test_bit(CACHE_VALID, &item->flags) &&
+		    !test_bit(CACHE_NEGATIVE, &item->flags))
+			auth_domain_put(&im->m_client->h);
 		kfree(im);
 	}
 }


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
