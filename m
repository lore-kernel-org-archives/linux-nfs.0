From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 4 - Fix problems when releasing cache item.
Date: Sun, 13 Oct 2002 21:42:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E180h8V-0000jT-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 180h8f-0007DH-00
	for <nfs@lists.sourceforge.net>; Sun, 13 Oct 2002 04:42:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 13 Oct 2002 21:42:22 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

When releasing a cache item we always release anything
that is part of the key, but we ONLY release the content
is if it is valid.  i.e. if CACHE_VALID but not CACHE_NEGATIVE.



 ----------- Diffstat output ------------
 ./fs/nfsd/export.c          |    3 ++-
 ./net/sunrpc/svcauth_unix.c |    4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

--- ./fs/nfsd/export.c	2002/10/12 12:11:39	1.1
+++ ./fs/nfsd/export.c	2002/10/12 12:15:40	1.2
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
--- ./net/sunrpc/svcauth_unix.c	2002/10/12 12:10:27	1.1
+++ ./net/sunrpc/svcauth_unix.c	2002/10/12 12:15:40	1.2
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
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
