From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] mountd: clean up hostname handling when
	authenticating	clients
Date: Wed, 25 Oct 2006 09:07:06 -0400
Message-ID: <1161781626.7078.53.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GciTU-0006cS-AK
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 06:07:16 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GciTQ-0008Dy-JF
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 06:07:17 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9PD7Cq1002109
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:12 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9PD76sW001693
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:06 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id k9PD76jD012144
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:06 -0400
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The current scheme for authenticating clients is what causes us to end
up with rmtab entries that look like this:

*:/foo 
*:/scratch
*,foo.bar.baz:/scratch

When a host is authenticated, we build a comma-separated list of
hostnames (via client_compose) and stuff that into the m_hostname field
of a static nfs_client struct. We then see if any of those hostnames
match any of the existing m_hostnames in the nfs_clients (via repeated
calls to client_member). Unfortunately, this means that when we later go
to do things like add the host to the kernel caches or the rmtab, it's
using a hostname like "*,foo.bar.baz".

This patch simplifies this scheme by getting rid of client_compose,
client_member, and a couple of helper functions only used by them. It
then adds a new client_resolve function that just turns an address into
a hostent. Instead of using client_member, we just make repeated calls
to client_check. This means we can now use the m_hostname field for this
struct as originally intended, to hold the hostname of the client.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.9/support/export/client.c.hname
+++ nfs-utils-1.0.9/support/export/client.c
@@ -234,102 +234,16 @@ client_find(struct hostent *hp)
 	return NULL;
 }
 
-/*
- * Find client name given an IP address
- * This is found by gathering all known names that match that IP address,
- * sorting them and joining them with '+'
- *
- */
-static char *add_name(char *old, char *add);
-
-char *
-client_compose(struct in_addr addr)
+struct hostent *
+client_resolve(struct in_addr addr)
 {
 	struct hostent *he = NULL;
-	char *name = NULL;
-	int i;
 
-	if (clientlist[MCL_WILDCARD] || clientlist[MCL_NETGROUP])
-		he = get_reliable_hostbyaddr((const char*)&addr, sizeof(addr), AF_INET);
+	he = get_reliable_hostbyaddr((const char*)&addr, sizeof(addr), AF_INET);
 	if (he == NULL)
 		he = get_hostent((const char*)&addr, sizeof(addr), AF_INET);
 
-	for (i = 0 ; i < MCL_MAXTYPES; i++) {
-		nfs_client	*clp;
-		for (clp = clientlist[i]; clp ; clp = clp->m_next) {
-			if (!client_check(clp, he))
-				continue;
-			name = add_name(name, clp->m_hostname);
-		}
-	}
-	return name;
-}
-
-int
-client_member(char *client, char *name)
-{
-	/* check if "client" (a ',' separated list of names)
-	 * contains 'name' as a member
-	 */
-	int l = strlen(name);
-	while (*client) {
-		if (strncmp(client, name, l) == 0 &&
-		    (client[l] == ',' || client[l] == '\0'))
-			return 1;
-		client = strchr(client, ',');
-		if (client == NULL)
-			return 0;
-		client++;
-	}
-	return 0;
-}
-
-
-int
-name_cmp(char *a, char *b)
-{
-	/* compare strings a and b, but only upto ',' in a */
-	while (*a && *b && *a != ',' && *a == *b)
-		a++, b++;
-	if (!*b && (!*a || !a == ',') )
-		return 0;
-	if (!*b) return 1;
-	if (!*a || *a == ',') return -1;
-	return *a - *b;
-}
-
-static char *
-add_name(char *old, char *add)
-{
-	int len = strlen(add)+2;
-	char *new;
-	char *cp;
-	if (old) len += strlen(old);
-	
-	new = malloc(len);
-	if (!new) {
-		free(old);
-		return NULL;
-	}
-	cp = old;
-	while (cp && *cp && name_cmp(cp, add) < 0) {
-		/* step cp forward over a name */
-		char *e = strchr(cp, ',');
-		if (e)
-			cp = e+1;
-		else
-			cp = cp + strlen(cp);
-	}
-	strncpy(new, old, cp-old);
-	new[cp-old] = 0;
-	if (cp != old && !*cp)
-		strcat(new, ",");
-	strcat(new, add);
-	if (cp && *cp) {
-		strcat(new, ",");
-		strcat(new, cp);
-	}
-	return new;
+	return he;
 }
 
 /*
--- nfs-utils-1.0.9/support/include/exportfs.h.hname
+++ nfs-utils-1.0.9/support/include/exportfs.h
@@ -55,8 +55,7 @@ int				client_check(nfs_client *, struct
 int				client_match(nfs_client *, char *hname);
 void				client_release(nfs_client *);
 void				client_freeall(void);
-char *				client_compose(struct in_addr addr);
-int 				client_member(char *client, char *name);
+struct hostent *		client_resolve(struct in_addr addr);
 
 int				export_read(char *fname);
 void				export_add(nfs_export *);
--- nfs-utils-1.0.9/utils/mountd/cache.c.hname
+++ nfs-utils-1.0.9/utils/mountd/cache.c
@@ -53,8 +53,8 @@ void auth_unix_ip(FILE *f)
 	char *cp;
 	char class[20];
 	char ipaddr[20];
-	char *client;
 	struct in_addr addr;
+	struct hostent *he;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -73,18 +73,16 @@ void auth_unix_ip(FILE *f)
 	auth_reload();
 
 	/* addr is a valid, interesting address, find the domain name... */
-	client = client_compose(addr);
-
+	he = client_resolve(addr);
 	
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
 	qword_printint(f, time(0)+30*60);
-	if (client)
-		qword_print(f, *client?client:"DEFAULT");
 	qword_eol(f);
+	if (he)
+		qword_print(f, *he->h_name?he->h_name:"DEFAULT");
 
-	if (client) free(client);
-	
+	if (he) free(he);
 }
 
 void nfsd_fh(FILE *f)
@@ -106,6 +104,7 @@ void nfsd_fh(FILE *f)
 	nfs_export *exp;
 	int i;
 	int dev_missing = 0;
+	struct hostent *hp = NULL;
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
@@ -167,11 +166,12 @@ void nfsd_fh(FILE *f)
 	auth_reload();
 
 	/* Now determine export point for this fsid/domain */
+	hp = gethostbyname(dom);
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
 			struct stat stb;
 
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!client_check(exp->m_client, hp))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -248,6 +248,7 @@ void nfsd_export(FILE *f)
 	int i;
 	char *dom, *path;
 	nfs_export *exp, *found = NULL;
+	struct hostent *hp;
 
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
@@ -268,9 +269,10 @@ void nfsd_export(FILE *f)
 	auth_reload();
 
 	/* now find flags for this export point in this domain */
+	hp = gethostbyname(dom);
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!client_check(exp->m_client, hp))
 				continue;
 			if (strcmp(path, exp->m_export.e_path))
 				continue;
--- nfs-utils-1.0.9/utils/mountd/auth.c.hname
+++ nfs-utils-1.0.9/utils/mountd/auth.c
@@ -79,16 +79,11 @@ auth_authenticate_internal(char *what, s
 		if (my_client.m_naddr != 1 ||
 		    my_client.m_addrlist[0].s_addr != caller->sin_addr.s_addr) {
 			/* different client to last time, so do a lookup */
-			char *n;
 			my_client.m_naddr = 0;
 			my_client.m_addrlist[0] = caller->sin_addr;
-			n = client_compose(caller->sin_addr);
-			*error = unknown_host;
-			if (!n)
-				return NULL;
-			strcpy(my_client.m_hostname, *n?n:"DEFAULT");
-			free(n);
 			my_client.m_naddr = 1;
+			strncpy(my_client.m_hostname, hp->h_name,
+					sizeof(my_client.m_hostname));
 		}
 
 		my_exp.m_client = &my_client;
@@ -96,7 +91,7 @@ auth_authenticate_internal(char *what, s
 		exp = NULL;
 		for (i = 0; !exp && i < MCL_MAXTYPES; i++) 
 			for (exp = exportlist[i]; exp; exp = exp->m_next) {
-				if (!client_member(my_client.m_hostname, exp->m_client->m_hostname))
+				if (!client_check(exp->m_client, hp))
 					continue;
 				if (strcmp(path, exp->m_export.e_path))
 					continue;



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
