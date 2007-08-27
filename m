From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/5] Create client_resolve and change client_compose
	to take a hostent arg
Date: Mon, 27 Aug 2007 11:22:06 -0400
Message-ID: <200708271522.l7RFM62p019425@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPgPo-0003ba-60
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 08:22:08 -0700
Received: from mx2.redhat.com ([66.187.237.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IPgPs-0003EV-ES
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 08:22:12 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx2.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFMAZ6008234
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:22:11 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFM95C016695
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:22:09 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFM680010363
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:22:06 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id l7RFM6ev019426
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:22:06 -0400
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

This moves the resolution of IP address to hostent into a helper function
and has other functions call it. Having client_compose take a hostent arg
allows us to avoid an extra hostname lookup in the auth_authenticate
codepath as well. Instead of redoing this lookup in client_compose, we can
simply reuse the hostent that was already generated in auth_authenticate.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---
 support/export/client.c    |   22 ++++++++++++++--------
 support/include/exportfs.h |    3 ++-
 utils/mountd/auth.c        |    8 ++------
 utils/mountd/cache.c       |    5 ++++-
 4 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index d1369f8..33c5432 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -235,6 +235,19 @@ client_find(struct hostent *hp)
 	return NULL;
 }
 
+struct hostent *
+client_resolve(struct in_addr addr)
+{
+	struct hostent *he = NULL;
+
+	if (clientlist[MCL_WILDCARD] || clientlist[MCL_NETGROUP])
+		he = get_reliable_hostbyaddr((const char*)&addr, sizeof(addr), AF_INET);
+	if (he == NULL)
+		he = get_hostent((const char*)&addr, sizeof(addr), AF_INET);
+
+	return he;
+}
+
 /*
  * Find client name given an IP address
  * This is found by gathering all known names that match that IP address,
@@ -244,17 +257,11 @@ client_find(struct hostent *hp)
 static char *add_name(char *old, char *add);
 
 char *
-client_compose(struct in_addr addr)
+client_compose(struct hostent *he)
 {
-	struct hostent *he = NULL;
 	char *name = NULL;
 	int i;
 
-	if (clientlist[MCL_WILDCARD] || clientlist[MCL_NETGROUP])
-		he = get_reliable_hostbyaddr((const char*)&addr, sizeof(addr), AF_INET);
-	if (he == NULL)
-		he = get_hostent((const char*)&addr, sizeof(addr), AF_INET);
-
 	for (i = 0 ; i < MCL_MAXTYPES; i++) {
 		nfs_client	*clp;
 		for (clp = clientlist[i]; clp ; clp = clp->m_next) {
@@ -263,7 +270,6 @@ client_compose(struct in_addr addr)
 			name = add_name(name, clp->m_hostname);
 		}
 	}
-	free(he);
 	return name;
 }
 
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index a491b1a..c1ba543 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -64,7 +64,8 @@ int				client_check(nfs_client *, struct hostent *);
 int				client_match(nfs_client *, char *hname);
 void				client_release(nfs_client *);
 void				client_freeall(void);
-char *				client_compose(struct in_addr addr);
+char *				client_compose(struct hostent *he);
+struct hostent *		client_resolve(struct in_addr addr);
 int 				client_member(char *client, char *name);
 
 int				export_read(char *fname);
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index c452a16..408c990 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -89,7 +89,7 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 		/* return static nfs_export with details filled in */
 		char *n;
 		my_client.m_addrlist[0] = caller->sin_addr;
-		n = client_compose(caller->sin_addr);
+		n = client_compose(hp);
 		*error = unknown_host;
 		if (!n)
 			return NULL;
@@ -161,11 +161,7 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 	epath[sizeof (epath) - 1] = '\0';
 	auth_fixpath(epath); /* strip duplicate '/' etc */
 
-	hp = get_reliable_hostbyaddr((const char*)&caller->sin_addr, sizeof(struct in_addr),
-				     AF_INET);
-	if (!hp)
-		hp = get_hostent((const char*)&caller->sin_addr, sizeof(struct in_addr),
-				     AF_INET);
+	hp = client_resolve(caller->sin_addr);
 	if (!hp)
 		return exp;
 
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 77fee01..f30f5b3 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -76,6 +76,7 @@ void auth_unix_ip(FILE *f)
 	char ipaddr[20];
 	char *client;
 	struct in_addr addr;
+	struct hostent *he;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -94,7 +95,8 @@ void auth_unix_ip(FILE *f)
 	auth_reload();
 
 	/* addr is a valid, interesting address, find the domain name... */
-	client = client_compose(addr);
+	he = client_resolve(addr);
+	client = client_compose(he);
 
 	
 	qword_print(f, "nfsd");
@@ -105,6 +107,7 @@ void auth_unix_ip(FILE *f)
 	qword_eol(f);
 
 	if (client) free(client);
+	if (he) free(he);
 	
 }
 
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
