From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 11 - nfsd_gss_rsc_lookup_free.patch
Date: Fri, 28 May 2004 14:37:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7b-0008EX-0j@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkZE-0006pF-Qr
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:56 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkZE-0006u9-9v
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:56 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
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


rsc_lookup is a bit complicated: it either takes responsibility for the memory
pointed to by handle.data and sets handle.data to NULL, or it leaves
handle.data unchanged, in which case the caller is responsible for freeing
handle.data.  I forgot that the possibility of inserting a negative cache entry
into the cache meant that this could happen even when rsc_lookup is called with
set == 0.

Note that the ip_map code has the same bug, not that it seems to matter much,
since the memory in question in that case is always just a statically allocated
string.



From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./net/sunrpc/auth_gss/svcauth_gss.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-05-28 14:20:17.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-05-28 14:20:17.000000000 +1000
@@ -333,6 +333,7 @@ rsc_init(struct rsc *new, struct rsc *tm
 	new->handle.data = tmp->handle.data;
 	tmp->handle.data = NULL;
 	new->mechctx = NULL;
+	new->cred.cr_group_info = NULL;
 }
 
 static inline void
@@ -453,8 +454,11 @@ gss_svc_searchbyctx(struct xdr_netobj *h
 	struct rsc rsci;
 	struct rsc *found;
 
-	rsci.handle = *handle;
+	memset(&rsci, 0, sizeof(rsci));
+	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
+		return NULL;
 	found = rsc_lookup(&rsci, 0);
+	rsc_free(&rsci);
 	if (!found)
 		return NULL;
 	if (cache_check(&rsc_cache, &found->h, NULL))


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
