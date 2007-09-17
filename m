From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/5] mountd: Change nfs_client->m_hostname to be a
	dynamically-allocated string
Date: Mon, 17 Sep 2007 08:51:59 -0400
Message-ID: <200709171251.l8HCpxeI025380@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXG5B-00016Q-Kn
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 05:52:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXG5E-0003Tt-6x
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 05:52:14 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Change nfs_client->m_hostname to be dynamically allocated rather than a
fixed length array of size NFSCLNT_IDMAX. This also adds a bit of
micro-optimization in a few places since it reduces the amount of string
copying that needs to be done.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---
 support/export/client.c    |   15 +++++++--------
 support/include/exportfs.h |    2 +-
 utils/mountd/auth.c        |    9 +++++++--
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 19b53aa..1754aa0 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -118,6 +118,7 @@ client_dup(nfs_client *clp, struct hostent *hp)
 	new = (nfs_client *) xmalloc(sizeof(*new));
 	memcpy(new, clp, sizeof(*new));
 	new->m_type = MCL_FQDN;
+	new->m_hostname = NULL;
 
 	client_init(new, (char *) hp->h_name, hp);
 	client_add(new);
@@ -127,14 +128,11 @@ client_dup(nfs_client *clp, struct hostent *hp)
 static void
 client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 {
-	if (hp) {
-		strncpy(clp->m_hostname, hp->h_name,
-			sizeof (clp->m_hostname) -  1);
-	} else {
-		strncpy(clp->m_hostname, hname,
-			sizeof (clp->m_hostname) - 1);
-	}
-	clp->m_hostname[sizeof (clp->m_hostname) - 1] = '\0';
+	xfree(clp->m_hostname);
+	if (hp)
+		clp->m_hostname = xstrdup(hp->h_name);
+	else
+		clp->m_hostname = xstrdup(hname);
 
 	clp->m_exported = 0;
 	clp->m_count = 0;
@@ -207,6 +205,7 @@ client_freeall(void)
 		head = clientlist + i;
 		while (*head) {
 			*head = (clp = *head)->m_next;
+			xfree(clp->m_hostname);
 			xfree(clp);
 		}
 	}
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 431b5ce..a491b1a 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -32,7 +32,7 @@ enum {
 
 typedef struct mclient {
 	struct mclient *	m_next;
-	char			m_hostname[NFSCLNT_IDMAX+1];
+	char *			m_hostname;
 	int			m_type;
 	int			m_naddr;
 	struct in_addr		m_addrlist[NFSCLNT_ADDRMAX];
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index f7fe23d..950ea20 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -93,8 +93,13 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 		*error = unknown_host;
 		if (!n)
 			return NULL;
-		strcpy(my_client.m_hostname, *n?n:"DEFAULT");
-		free(n);
+		free(my_client.m_hostname);
+		if (*n) {
+			my_client.m_hostname = n;
+		} else {
+			free(n);
+			my_client.m_hostname = xstrdup("DEFAULT");
+		}
 		my_client.m_naddr = 1;
 		my_exp.m_client = &my_client;
 
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
