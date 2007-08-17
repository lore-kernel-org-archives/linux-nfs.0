From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/4] Add mountd command line option to change how
 IP addrs are mapped
Date: Fri, 17 Aug 2007 17:24:39 -0400
Message-ID: <20070817172439.854b14dc.jlayton@redhat.com>
References: <200708141333.l7EDX46J032156@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM9J7-0003K8-W5
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 14:24:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IM9JB-0002NO-ID
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 14:24:42 -0700
In-Reply-To: <200708141333.l7EDX46J032156@dantu.rdu.redhat.com>
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

On Tue, 14 Aug 2007 09:33:04 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> If a host is a member of a large number of netgroups, it becomes easily
> possible for client_compose to generate a m_hostname string that overflows
> the maximum string length allowed by the kernel caches.
> 
> This patch adds a new mountd command-line option to tell it to have the
> auth.unix.ip cache map IP address to IP address. With this flag, mountd
> doesn't bother using client_compose to build the m_hostname string. It just
> populates it with the dotted-quad ip address. When mountd handles a mount
> request, it then has an IP address and a path. It then calls client_check
> to check the host against export entries where the path has already matched.
> 
> Since we don't bother looking up netgroups which have no relation to the
> mount, this can be a big performance gain in netgroup-heavy configurations.
> The downside is that every host has a corresponding entry in the nfsd.export
> and nfsd.fh caches as well as the auth.unix.ip cache.
> 
> For now this behavior is manually selectable, but ideally we'd probably
> want to automatically enable it based on some heuristic. I'm just not yet
> sure what that heuristic should be...
> 

A respin of the above patch follows. This is essentially the same patch,
but I added a mechanism to automatically enable the "use_ipaddr" mode. The 
criteria I settled on for now, is this:

If the total length of all m_hostnames in the MCL_NETGROUP list is more
than half NFSCLNT_IDMAX, then switch to the "use_ipaddr" mode.

I considered doing what Neil suggested and just using all of the
m_hostnames from all of the clientlists. Consider however a
diskless client setup where someone has a ton of exports all
exported to different IP addresses. We probably don't want to enable
this there, but it would probably be enabled if we based this on
all of the m_hostnames.

I figure someone will want to enable this new mode for 2 reasons:

1) a client is likely to overflow NFSCLNT_IDMAX (which is a decent
approximation of the max length of a line in the kernel cache)

...or...

2) we have a lot of netgroups in /etc/exports and resolving them all
for a single mount is prohibitively expensive

I think the only reasonable way to end up in situation #1 is if you
are dealing with a lot of netgroups. A client isn't likely to match
a bunch of different MCL_WILDCARD entries (though maybe it can), nor is
it likely to match a bunch of different MCL_SUBNET entries. So it
really only makes sense to pay attention to the MCL_NETGROUP list
for this.

Why NFSCLNT_IDMAX/2? No particular reason. I figured that would mean
that we had a lot of netgroups, but still had enough space in the
string to allow for non-netgroup matches.

I'm not firmly attached to this particular logic, however, and am
definitely open to suggestions. I do however think that we need
to strive to make this work automatically. It's going to be
tough to explain to a sysadmin why and when they need to enable
this manually.

Also, I made it so that we reevaluate this decision in auth_reload
when a new export table is loaded. If the decision changes then I
have the code doing a cache_flush. I'm not certain if that's
necessary here. Is it?

----------[snip]----------

If a host is a member of a large number of netgroups, it becomes easily
possible for client_compose to generate a m_hostname string that
overflows the maximum string length allowed by the kernel caches.

This patch adds a new mountd command-line option to tell it to have the
auth.unix.ip cache map IP address to IP address. With this flag, mountd
doesn't bother using client_compose to build the m_hostname string. It
just populates it with the dotted-quad ip address. When mountd handles
a mount request, it then has an IP address and a path. It then calls
client_check to check the host against export entries where the path
has already matched.

Since we don't bother looking up netgroups which have no relation to the
mount, this can be a big performance gain in netgroup-heavy
configurations. The downside is that every host has a corresponding
entry in the nfsd.export and nfsd.fh caches as well as the auth.unix.ip
cache.

This behavior is manually selectable via a command-line option (-i), and
will be automatically enabled if the length of all of the concatenated
netgroup names in the export table is longer than half NFSCLNT_IDMAX.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

---
 utils/mountd/auth.c   |   59 +++++++++++++++++++++++++++++++++++++++----------
 utils/mountd/cache.c  |   45 ++++++++++++++++++++++++++++++------
 utils/mountd/mountd.c |    9 ++++++-
 3 files changed, 92 insertions(+), 21 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 408c990..2be441e 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -37,6 +37,8 @@ static nfs_export my_exp;
 static nfs_client my_client;
 
 extern int new_cache;
+extern int force_ipaddr;
+extern int use_ipaddr;
 
 void
 auth_init(char *exports)
@@ -47,6 +49,29 @@ auth_init(char *exports)
 	xtab_mount_write();
 }
 
+static void
+check_useipaddr()
+{
+	nfs_client *clp;
+	int old_use_ipaddr = use_ipaddr;
+	unsigned int len = 0;
+
+	if (force_ipaddr >= 0)
+		return;
+
+	for (clp = clientlist[MCL_NETGROUP]; clp; clp = clp->m_next)
+		len += strlen(clp->m_hostname);
+
+	if (len > (NFSCLNT_IDMAX / 2))
+		use_ipaddr = 1;
+	else
+		use_ipaddr = 0;
+
+	if (use_ipaddr != old_use_ipaddr)
+		cache_flush(1);
+
+}
+
 unsigned int
 auth_reload()
 {
@@ -72,6 +97,7 @@ auth_reload()
 	export_freeall();
 	memset(&my_client, 0, sizeof(my_client));
 	xtab_export_read();
+	check_useipaddr();
 	++counter;
 
 	return counter;
@@ -88,29 +114,38 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
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
index 999f035..2c59569 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -40,6 +40,8 @@ static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, mountstat3 *,
 int reverse_resolve = 0;
 int new_cache = 0;
 int manage_gids;
+int use_ipaddr = -1;
+int force_ipaddr = -1;
 
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
@@ -70,6 +72,7 @@ static struct option longopts[] =
 	{ "num-threads", 1, 0, 't' },
 	{ "reverse-lookup", 0, 0, 'r' },
 	{ "manage-gids", 0, 0, 'g' },
+	{ "use-ipaddr", 0, 0, 'i' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -569,7 +572,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:nFd:f:ip:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'g':
 			manage_gids = 1;
@@ -597,6 +600,10 @@ main(int argc, char **argv)
 		case 'h':
 			usage(argv [0], 0);
 			break;
+		case 'i':
+			force_ipaddr = 1;
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
