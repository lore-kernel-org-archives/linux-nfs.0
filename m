From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 16] svcrpc: auth_domain documentation
Date: Tue, 22 Mar 2005 16:42:00 +1100
Message-ID: <E1DDc9Q-0002K5-Vr@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDc9c-0006kk-Pd
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:12 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9b-00056K-K8
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:12 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The use of auth_domains is somewhat confusing, in part because they were
originally intended to be used in a more general way than they currently are.

Update the documentation a little with an eye towards how it's currently used.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./include/linux/sunrpc/svcauth.h |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff ./include/linux/sunrpc/svcauth.h~current~ ./include/linux/sunrpc/svcauth.h
--- ./include/linux/sunrpc/svcauth.h~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./include/linux/sunrpc/svcauth.h	2005-03-22 16:36:34.000000000 +1100
@@ -26,21 +26,23 @@ struct svc_cred {
 struct svc_rqst;		/* forward decl */
 
 /* Authentication is done in the context of a domain.
- * For a server, a domain represents a group of clients using
+ *
+ * Currently, the nfs server uses the auth_domain to stand
+ * for the "client" listed in /etc/exports.
+ *
+ * More generally, a domain might represent a group of clients using
  * a common mechanism for authentication and having a common mapping
  * between local identity (uid) and network identity.  All clients
  * in a domain have similar general access rights.  Each domain can
  * contain multiple principals which will have different specific right
  * based on normal Discretionary Access Control.
  *
- * For a client, a domain represents a number of servers which all
- * use a common authentication mechanism and network identity name space.
- *
  * A domain is created by an authentication flavour module based on name
  * only.  Userspace then fills in detail on demand.
  *
- * The creation of a domain typically implies creation of one or
- * more caches for storing domain specific information.
+ * In the case of auth_unix and auth_null, the auth_domain is also
+ * associated with entries in another cache representing the mapping
+ * of ip addresses to the given client.
  */
 struct auth_domain {
 	struct	cache_head	h;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
