From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 15 - rpc/svc auth_unix tidyup
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002XV-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKlh-0002XV-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:05 +1100
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

Get auth_unix_lookup (maps IP address to clientname)
to use cache_check instead of checking the various state
bits manually.



 ----------- Diffstat output ------------
 ./net/sunrpc/svcauth_unix.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-01-06 09:57:07.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2003-01-06 09:57:07.000000000 +1100
@@ -268,20 +268,17 @@ struct auth_domain *auth_unix_lookup(str
 
 	if (!ipm)
 		return NULL;
+	if (cache_check(&ip_map_cache, &ipm->h, NULL))
+		return NULL;
 
-	if (test_bit(CACHE_VALID, &ipm->h.flags) &&
-	    (ipm->m_client->addr_changes - ipm->m_add_change) >0)
+	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
 		set_bit(CACHE_NEGATIVE, &ipm->h.flags);
-
-	if (!test_bit(CACHE_VALID, &ipm->h.flags))
-		rv = NULL;
-	else if (test_bit(CACHE_NEGATIVE, &ipm->h.flags))
 		rv = NULL;
-	else {
+	} else {
 		rv = &ipm->m_client->h;
 		cache_get(&rv->h);
 	}
-	if (ipm) ip_map_put(&ipm->h, &ip_map_cache);
+	ip_map_put(&ipm->h, &ip_map_cache);
 	return rv;
 }
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
