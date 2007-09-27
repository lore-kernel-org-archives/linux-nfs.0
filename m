From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/5] rpc.mountd: add new mode for handling
	netgroup-heavy configurations
Date: Thu, 27 Sep 2007 06:54:04 -0400
Message-ID: <200709271054.l8RAs4MX031636@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iar0P-00070N-Ts
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 03:54:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iar0T-0003TX-1o
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 03:54:11 -0700
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

If a host is a member of a large number of netgroups, it becomes easily
possible for client_compose to generate a m_hostname string that
overflows the maximum string length allowed by the kernel caches.

This patch adds a new mode for mountd where it will map IP address to IP
address in the auth.unix.ip cache. When this enabled, mountd doesn't
bother using client_compose to build the m_hostname string. It just
populates it with the dotted-quad ip address. When mountd handles a
mount request, it then has an IP address and a path. It then calls
client_check to check the host against export entries where the path has
already matched.

Since we don't bother looking up netgroups which have no relation to the
mount, this can be a big performance gain in netgroup-heavy
configurations.  The downside is that every host has a corresponding
entry in the nfsd.export and nfsd.fh caches as well as the auth.unix.ip
cache.

The new behavior is automatically enabled if the length of all of the
concatenated netgroup names in the export table is longer than half
NFSCLNT_IDMAX. The rationale for this logic is that this should allow
for a host to be a member of a long list of netgroups while still
allowing for other matches.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/auth.c   |   61 ++++++++++++++++++++++++++++++++++++++++---------
 utils/mountd/cache.c  |   44 +++++++++++++++++++++++++++++------
 utils/mountd/mountd.c |    1 +
 3 files changed, 87 insertions(+), 19 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 84fea30..a821c13 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -37,6 +37,7 @@ static nfs_export my_exp;
 static nfs_client my_client;
 
 extern int new_cache;
+extern int use_ipaddr;
 
 void
 auth_init(char *exports)
@@ -47,6 +48,34 @@ auth_init(char *exports)
 	xtab_mount_write();
 }
 
+/*
+ * A client can match many different netgroups and it's tough to know
+ * beforehand whether it will. If the concatenated string of netgroup
+ * m_hostnames is >512 bytes, then enable the "use_ipaddr" mode. This
+ * makes mountd change how it matches a client ip address when a mount
+ * request comes in. It's more efficient at handling netgroups at the
+ * expense of larger kernel caches.
+ */
+static void
+check_useipaddr()
+{
+	nfs_client *clp;
+	int old_use_ipaddr = use_ipaddr;
+	unsigned int len = 0;
+
+	/* add length of m_hostname + 1 for the comma */
+	for (clp = clientlist[MCL_NETGROUP]; clp; clp = clp->m_next)
+		len += (strlen(clp->m_hostname) + 1);
+
+	if (len > (NFSCLNT_IDMAX / 2))
+		use_ipaddr = 1;
+	else
+		use_ipaddr = 0;
+
+	if (use_ipaddr != old_use_ipaddr)
+		cache_flush(1);
+}
+
 unsigned int
 auth_reload()
 {
@@ -72,6 +101,7 @@ auth_reload()
 	export_freeall();
 	memset(&my_client, 0, sizeof(my_client));
 	xtab_export_read();
+	check_useipaddr();
 	++counter;
 
 	return counter;
@@ -88,28 +118,37 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 		int i;
 		/* return static nfs_export with details filled in */
 		char *n;
-		my_client.m_addrlist[0] = caller->sin_addr;
-		n = client_compose(hp);
-		*error = unknown_host;
-		if (!n)
-			return NULL;
 		free(my_client.m_hostname);
-		if (*n) {
-			my_client.m_hostname = n;
+		if (use_ipaddr) {
+			my_client.m_hostname =
+				strdup(inet_ntoa(caller->sin_addr));
 		} else {
-			free(n);
-			my_client.m_hostname = xstrdup("DEFAULT");
+			n = client_compose(hp);
+			*error = unknown_host;
+			if (!n)
+				my_client.m_hostname = NULL;
+			else if (*n)
+				my_client.m_hostname = n;
+			else {
+				free(n);
+				my_client.m_hostname = strdup("DEFAULT");
+			}
 		}
+		if (my_client.m_hostname == NULL)
+			return NULL;
 		my_client.m_naddr = 1;
+		my_client.m_addrlist[0] = caller->sin_addr;
 		my_exp.m_client = &my_client;
 
 		exp = NULL;
 		for (i = 0; !exp && i < MCL_MAXTYPES; i++) 
 			for (exp = exportlist[i]; exp; exp = exp->m_next) {
-				if (!client_member(my_client.m_hostname, exp->m_client->m_hostname))
-					continue;
 				if (strcmp(path, exp->m_export.e_path))
 					continue;
+				if (!use_ipaddr && !client_member(my_client.m_hostname, exp->m_client->m_hostname))
+					continue;
+				if (use_ipaddr && !client_check(exp->m_client, hp))
+					continue;
 				break;
 			}
 		*error = not_exported;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ef460f7..ce1a5a9 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -61,6 +61,7 @@ int cache_export_ent(char *domain, struct exportent *exp, char *p);
 
 char *lbuf  = NULL;
 int lbuflen = 0;
+extern int use_ipaddr;
 
 void auth_unix_ip(FILE *f)
 {
@@ -74,9 +75,9 @@ void auth_unix_ip(FILE *f)
 	char *cp;
 	char class[20];
 	char ipaddr[20];
-	char *client;
+	char *client = NULL;
 	struct in_addr addr;
-	struct hostent *he;
+	struct hostent *he = NULL;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -95,14 +96,17 @@ void auth_unix_ip(FILE *f)
 	auth_reload();
 
 	/* addr is a valid, interesting address, find the domain name... */
-	he = client_resolve(addr);
-	client = client_compose(he);
-
+	if (!use_ipaddr) {
+		he = client_resolve(addr);
+		client = client_compose(he);
+	}
 	
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
 	qword_printint(f, time(0)+30*60);
-	if (client)
+	if (use_ipaddr)
+		qword_print(f, ipaddr);
+	else if (client)
 		qword_print(f, *client?client:"DEFAULT");
 	qword_eol(f);
 
@@ -266,6 +270,8 @@ void nfsd_fh(FILE *f)
 	unsigned int fsidnum=0;
 	char fsid[32];
 	struct exportent *found = NULL;
+	struct hostent *he = NULL;
+	struct in_addr addr;
 	char *found_path = NULL;
 	nfs_export *exp;
 	int i;
@@ -391,7 +397,7 @@ void nfsd_fh(FILE *f)
 				next_exp = exp->m_next;
 			}
 
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -443,6 +449,15 @@ void nfsd_fh(FILE *f)
 				continue;
 #endif
 			}
+			if (use_ipaddr) {
+				if (he == NULL) {
+					if (!inet_aton(dom, &addr))
+						goto out;
+					he = client_resolve(addr);
+				}
+				if (!client_check(exp->m_client, he))
+					continue;
+			}
 			/* It's a match !! */
 			if (!found) {
 				found = &exp->m_export;
@@ -497,6 +512,7 @@ void nfsd_fh(FILE *f)
 	qword_eol(f);
  out:
 	free(found_path);
+	free(he);
 	free(dom);
 	return;		
 }
@@ -584,6 +600,8 @@ void nfsd_export(FILE *f)
 	char *dom, *path;
 	nfs_export *exp, *found = NULL;
 	int found_type = 0;
+	struct in_addr addr;
+	struct hostent *he = NULL;
 
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
@@ -606,7 +624,7 @@ void nfsd_export(FILE *f)
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
 				/* if path is a mountpoint below e_path, then OK */
@@ -620,6 +638,15 @@ void nfsd_export(FILE *f)
 					continue;
 			} else if (strcmp(path, exp->m_export.e_path) != 0)
 				continue;
+			if (use_ipaddr) {
+				if (he == NULL) {
+					if (!inet_aton(dom, &addr))
+						goto out;
+					he = client_resolve(addr);
+				}
+				if (!client_check(exp->m_client, he))
+					continue;
+			}
 			if (!found) {
 				found = exp;
 				found_type = i;
@@ -661,6 +688,7 @@ void nfsd_export(FILE *f)
  out:
 	if (dom) free(dom);
 	if (path) free(path);
+	if (he) free(he);
 }
 
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 999f035..4a50588 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -40,6 +40,7 @@ static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, mountstat3 *,
 int reverse_resolve = 0;
 int new_cache = 0;
 int manage_gids;
+int use_ipaddr = -1;
 
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
