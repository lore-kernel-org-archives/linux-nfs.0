From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] libexport.a: Clean up client_compose() and client_member()
Date: Sun, 21 Mar 2010 20:38:14 -0400
Message-ID: <20100322003814.30360.34486.stgit@localhost.localdomain>
References: <20100322003317.30360.18289.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:16671 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab0CVAiR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 20:38:17 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1035473qwh.37
        for <linux-nfs@vger.kernel.org>; Sun, 21 Mar 2010 17:38:17 -0700 (PDT)
In-Reply-To: <20100322003317.30360.18289.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Replace outdated comments, and fix some function
declarations.  Use proper type for a couple of automatic variables.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c    |   43 +++++++++++++++++++++++++++----------------
 support/include/exportfs.h |    3 ++-
 2 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index f8c84de..5e937b0 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -28,6 +28,8 @@
 #if !defined(__GLIBC__) || __GLIBC__ < 2
 extern int	innetgr(char *netgr, char *host, char *, char *);
 #endif
+
+static char	*add_name(char *old, const char *add);
 static void	client_init(nfs_client *clp, const char *hname,
 					struct hostent *hp);
 static int	client_checkaddr(nfs_client *clp, struct in_addr addr);
@@ -224,14 +226,18 @@ client_resolve(struct in_addr addr)
 	return he;
 }
 
-/*
- * Find client name given an IP address
- * This is found by gathering all known names that match that IP address,
- * sorting them and joining them with '+'
+/**
+ * client_compose - Make a list of cached hostnames that match an IP address
+ * @he: pointer to hostent containing IP address information to match
+ *
+ * Gather all known client hostnames that match the IP address, and sort
+ * the result into a comma-separated list.
  *
+ * Returns a '\0'-terminated ASCII string containing a comma-separated
+ * sorted list of client hostnames, or NULL if no client records matched
+ * the IP address or memory could not be allocated.  Caller must free the
+ * returned string with free(3).
  */
-static char *add_name(char *old, char *add);
-
 char *
 client_compose(struct hostent *he)
 {
@@ -249,13 +255,19 @@ client_compose(struct hostent *he)
 	return name;
 }
 
+/**
+ * client_member - check if @name is contained in the list @client
+ * @client: '\0'-terminated ASCII string containing
+ *		comma-separated list of hostnames
+ * @name: '\0'-terminated ASCII string containing hostname to look for
+ *
+ * Returns 1 if @name was found in @client, otherwise zero is returned.
+ */
 int
-client_member(char *client, char *name)
+client_member(const char *client, const char *name)
 {
-	/* check if "client" (a ',' separated list of names)
-	 * contains 'name' as a member
-	 */
-	int l = strlen(name);
+	size_t l = strlen(name);
+
 	while (*client) {
 		if (strncmp(client, name, l) == 0 &&
 		    (client[l] == ',' || client[l] == '\0'))
@@ -268,9 +280,8 @@ client_member(char *client, char *name)
 	return 0;
 }
 
-
-int
-name_cmp(char *a, char *b)
+static int
+name_cmp(const char *a, const char *b)
 {
 	/* compare strings a and b, but only upto ',' in a */
 	while (*a && *b && *a != ',' && *a == *b)
@@ -283,9 +294,9 @@ name_cmp(char *a, char *b)
 }
 
 static char *
-add_name(char *old, char *add)
+add_name(char *old, const char *add)
 {
-	int len = strlen(add)+2;
+	size_t len = strlen(add) + 2;
 	char *new;
 	char *cp;
 	if (old) len += strlen(old);
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 3eb03d9..9a19cbb 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -77,7 +77,8 @@ void				client_release(nfs_client *);
 void				client_freeall(void);
 char *				client_compose(struct hostent *he);
 struct hostent *		client_resolve(struct in_addr addr);
-int 				client_member(char *client, char *name);
+int 				client_member(const char *client,
+						const char *name);
 
 int				export_read(char *fname);
 void			export_add(nfs_export *);

