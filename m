From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/4] Change nfs_client->m_hostname to be a
	dynamically-allocated string
Date: Tue, 14 Aug 2007 09:32:48 -0400
Message-ID: <200708141332.l7EDWms3032139@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKwVr-0005uD-UZ
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 06:32:48 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKwVu-0007W4-P6
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 06:32:52 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDWnxK030316
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:49 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDWnpp006454
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:49 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDWnBa001770
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:49 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.14.1/8.13.8) with ESMTP id l7EDWmAj032140
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:48 -0400
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
---
 support/export/client.c    |   17 +++++++++--------
 support/include/exportfs.h |    2 +-
 utils/mountd/auth.c        |   10 ++++++++--
 3 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 19b53aa..d1369f8 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -118,6 +118,7 @@ client_dup(nfs_client *clp, struct hostent *hp)
 	new = (nfs_client *) xmalloc(sizeof(*new));
 	memcpy(new, clp, sizeof(*new));
 	new->m_type = MCL_FQDN;
+	new->m_hostname = NULL;
 
 	client_init(new, (char *) hp->h_name, hp);
 	client_add(new);
@@ -127,14 +128,12 @@ client_dup(nfs_client *clp, struct hostent *hp)
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
+	if (clp->m_hostname)
+		xfree(clp->m_hostname);
+	if (hp)
+		clp->m_hostname = xstrdup(hp->h_name);
+	else
+		clp->m_hostname = xstrdup(hname);
 
 	clp->m_exported = 0;
 	clp->m_count = 0;
@@ -207,6 +206,8 @@ client_freeall(void)
 		head = clientlist + i;
 		while (*head) {
 			*head = (clp = *head)->m_next;
+			if (clp->m_hostname != NULL)
+				xfree(clp->m_hostname);
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
index f7fe23d..c452a16 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -93,8 +93,14 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 		*error = unknown_host;
 		if (!n)
 			return NULL;
-		strcpy(my_client.m_hostname, *n?n:"DEFAULT");
-		free(n);
+		if (my_client.m_hostname != NULL)
+			free(my_client.m_hostname);
+		if (*n) {
+			my_client.m_hostname = n;
+		} else {
+			free(n);
+			my_client.m_hostname = xstrdup("DEFAULT");
+		}
 		my_client.m_naddr = 1;
 		my_exp.m_client = &my_client;
 
-- 
1.5.2.2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
