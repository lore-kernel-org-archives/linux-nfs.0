From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] Add mountd command line option to change how IP
	addrs are mapped
Date: Tue, 14 Aug 2007 09:33:04 -0400
Message-ID: <200708141333.l7EDX46J032156@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKwW6-0005vj-Iv
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 06:33:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKwWA-0007eK-10
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 06:33:06 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDX5ex030501
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:33:05 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDX4vo006525
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:33:04 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDX4rd001824
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:33:04 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.14.1/8.13.8) with ESMTP id l7EDX4xE032157
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:33:04 -0400
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
possible for client_compose to generate a m_hostname string that overflows
the maximum string length allowed by the kernel caches.

This patch adds a new mountd command-line option to tell it to have the
auth.unix.ip cache map IP address to IP address. With this flag, mountd
doesn't bother using client_compose to build the m_hostname string. It just
populates it with the dotted-quad ip address. When mountd handles a mount
request, it then has an IP address and a path. It then calls client_check
to check the host against export entries where the path has already matched.

Since we don't bother looking up netgroups which have no relation to the
mount, this can be a big performance gain in netgroup-heavy configurations.
The downside is that every host has a corresponding entry in the nfsd.export
and nfsd.fh caches as well as the auth.unix.ip cache.

For now this behavior is manually selectable, but ideally we'd probably
want to automatically enable it based on some heuristic. I'm just not yet
sure what that heuristic should be...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mountd/auth.c   |   34 ++++++++++++++++++++++------------
 utils/mountd/cache.c  |   45 +++++++++++++++++++++++++++++++++++++--------
 utils/mountd/mountd.c |    6 +++++-
 3 files changed, 64 insertions(+), 21 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 408c990..8061471 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -37,6 +37,7 @@ static nfs_export my_exp;
 static nfs_client my_client;
 
 extern int new_cache;
+extern int use_ipaddr;
 
 void
 auth_init(char *exports)
@@ -88,29 +89,38 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 		int i;
 		/* return static nfs_export with details filled in */
 		char *n;
-		my_client.m_addrlist[0] = caller->sin_addr;
-		n = client_compose(hp);
-		*error = unknown_host;
-		if (!n)
-			return NULL;
-		if (my_client.m_hostname != NULL)
+		if (my_client.m_hostname != NULL) {
 			free(my_client.m_hostname);
-		if (*n) {
-			my_client.m_hostname = n;
+			my_client.m_hostname = NULL;
+		}
+		if (use_ipaddr) {
+			my_client.m_hostname =
+				xstrdup(inet_ntoa(caller->sin_addr));
 		} else {
-			free(n);
-			my_client.m_hostname = xstrdup("DEFAULT");
+			n = client_compose(hp);
+			*error = unknown_host;
+			if (!n)
+				return NULL;
+			if (*n) {
+				my_client.m_hostname = n;
+			} else {
+				free(n);
+				my_client.m_hostname = xstrdup("DEFAULT");
+			}
 		}
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
index b6b0473..25248b8 100644
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
 
@@ -267,6 +271,8 @@ void nfsd_fh(FILE *f)
 	unsigned int fsidnum=0;
 	char fsid[32];
 	struct exportent *found = NULL;
+	struct hostent *he = NULL;
+	struct in_addr addr;
 	char *found_path = NULL;
 	nfs_export *exp;
 	int i;
@@ -392,7 +398,7 @@ void nfsd_fh(FILE *f)
 				next_exp = exp->m_next;
 			}
 
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -444,6 +450,15 @@ void nfsd_fh(FILE *f)
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
@@ -495,6 +510,8 @@ void nfsd_fh(FILE *f)
 		qword_print(f, found->e_path);
 	qword_eol(f);
  out:
+	if (he)
+		free(he);
 	free(dom);
 	return;		
 }
@@ -582,6 +599,8 @@ void nfsd_export(FILE *f)
 	char *dom, *path;
 	nfs_export *exp, *found = NULL;
 	int found_type = 0;
+	struct in_addr addr;
+	struct hostent *he = NULL;
 
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
@@ -604,7 +623,7 @@ void nfsd_export(FILE *f)
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
 				/* if path is a mountpoint below e_path, then OK */
@@ -618,6 +637,15 @@ void nfsd_export(FILE *f)
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
@@ -659,6 +687,7 @@ void nfsd_export(FILE *f)
  out:
 	if (dom) free(dom);
 	if (path) free(path);
+	if (he) free(he);
 }
 
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 999f035..06a3471 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -40,6 +40,7 @@ static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, mountstat3 *,
 int reverse_resolve = 0;
 int new_cache = 0;
 int manage_gids;
+int use_ipaddr = 0;
 
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
@@ -569,7 +570,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:nFd:f:ip:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'g':
 			manage_gids = 1;
@@ -597,6 +598,9 @@ main(int argc, char **argv)
 		case 'h':
 			usage(argv [0], 0);
 			break;
+		case 'i':
+			use_ipaddr = 1;
+			break;
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
 			port = atoi(optarg);
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
