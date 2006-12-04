From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Mon, 4 Dec 2006 17:33:24 +1100
Message-ID: <17779.49460.590066.210744@cse.unsw.edu.au>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
	<45704A4A.6000007@poochiereds.net>
	<17779.42545.642976.873602@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gr7O8-0005PD-Ar
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 22:33:16 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gr7O8-0006NT-QC
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 22:33:17 -0800
To: Jeff Layton <jlayton@poochiereds.net>, nfs@lists.sourceforge.net
In-Reply-To: message from Neil Brown on Monday December 4
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

On Monday December 4, neilb@suse.de wrote:
> 
> Finally we could still leave the authentication the way it is and just
> fix up the rmtab entries.
> So whenever mountd gives info to the kernel, whether due to a mount
> request or an up-call, we write an appropriate IP:/dir to rmtab, and
> whenever an unmount request is received, we deleted the corresponding
> request.
> We could do this ignoring the current count in rmtab, and still have a
> fairly reliable system.  We would probably want to erase rmtab at boot
> time to stop it from collection cruft.
> 
> Actually, that sounds like it could be the best idea.  I'll have a go
> at that, but I'll post this patch (That gets info from the in-kernel
> cache) anyway.

I couldn't quite do that the way I had hoped as the info isn't
available at the right places.

However here is another patch for consideration.

It tries a bit harder to keep vaguely sensible information in rmtab
and if you run mounted with "-I", then "showmount -a" will list IP and
export-point of all current mounts ... as best as possible.
e.g. if you mount the same filesystem twice on the one client, then it
will appear once in "showmount -a".  If you then unmount one of them,
it will disappear.  But as soon as you access it again it will
re-appear. 

I think this is about the best I can do.

Does it meet the needs?

NeilBrown


diff --git a/support/export/client.c b/support/export/client.c
index 33dfdb0..19b6f1c 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -241,6 +241,7 @@ client_find(struct hostent *hp)
  *
  */
 static char *add_name(char *old, char *add);
+extern int use_ip_address;
 
 char *
 client_compose(struct in_addr addr)
@@ -249,6 +250,9 @@ client_compose(struct in_addr addr)
 	char *name = NULL;
 	int i;
 
+	if (use_ip_address)
+		return strdup(inet_ntoa(addr));
+
 	if (clientlist[MCL_WILDCARD] || clientlist[MCL_NETGROUP])
 		he = get_reliable_hostbyaddr((const char*)&addr, sizeof(addr), AF_INET);
 	if (he == NULL)
@@ -284,6 +288,25 @@ client_member(char *client, char *name)
 	return 0;
 }
 
+int client_matches(char *client, nfs_client *clp)
+{
+	struct hostent host;
+	struct in_addr *alist[2];
+	struct in_addr a;
+	if (! use_ip_address)
+		return client_member(client, clp->m_hostname);
+
+	host.h_addrtype = AF_INET;
+	host.h_length = 4;
+	host.h_name = client;
+	host.h_addr_list = (char*)alist;
+	alist[0] = &a;
+	alist[1] = NULL;
+	inet_aton(client, &a);
+	
+	return client_check(clp, &host);
+}
+
 
 int
 name_cmp(char *a, char *b)
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 10f38c7..1d05357 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -57,6 +57,7 @@ void				client_release(nfs_client *);
 void				client_freeall(void);
 char *				client_compose(struct in_addr addr);
 int 				client_member(char *client, char *name);
+int 				client_matches(char *client, nfs_client *clp);
 
 int				export_read(char *fname);
 void				export_add(nfs_export *);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index cd49a3b..5a5e8fe 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -33,6 +33,7 @@ static void	dump(int verbose);
 static void	error(nfs_export *exp, int err);
 static void	usage(void);
 
+int use_ip_address; /* Should not get used... */
 
 int
 main(int argc, char **argv)
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 44d9980..02a26e1 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -96,7 +96,7 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 		exp = NULL;
 		for (i = 0; !exp && i < MCL_MAXTYPES; i++) 
 			for (exp = exportlist[i]; exp; exp = exp->m_next) {
-				if (!client_member(my_client.m_hostname, exp->m_client->m_hostname))
+				if (!client_matches(my_client.m_hostname, exp->m_client))
 					continue;
 				if (strcmp(path, exp->m_export.e_path))
 					continue;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index c57d3b0..16d0ccd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -83,9 +83,6 @@ void auth_unix_ip(FILE *f)
 		qword_print(f, *client?client:"DEFAULT");
 	qword_eol(f);
 
-	if (client && strcmp(ipaddr, client))
-		mountlist_add(ipaddr, *client?client:"DEFAULT");
-
 	if (client) free(client);
 	
 }
@@ -174,7 +171,7 @@ void nfsd_fh(FILE *f)
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
 			struct stat stb;
 
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!client_matches(dom, exp->m_client))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -273,7 +270,7 @@ void nfsd_export(FILE *f)
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
-			if (!client_member(dom, exp->m_client->m_hostname))
+			if (!client_matches(dom, exp->m_client))
 				continue;
 			if (strcmp(path, exp->m_export.e_path))
 				continue;
@@ -377,6 +374,23 @@ void cache_export_ent(char *domain, struct exportent *exp)
 	mountlist_add(domain, exp->e_path);
 }
 
+void cache_export_flush(char *domain, struct exportent *exp)
+{
+
+	FILE *f = fopen("/proc/net/rpc/nfsd.export/channel", "w");
+	if (!f)
+		return;
+
+	qword_print(f, domain);
+	qword_print(f, exp->e_path);
+	qword_printint(f, time(0)-60);
+	qword_eol(f);
+
+	fclose(f);
+
+	mountlist_del(domain, exp->e_path, 1);
+}
+
 void cache_export(nfs_export *exp)
 {
 	FILE *f;
@@ -393,9 +407,6 @@ void cache_export(nfs_export *exp)
 	
 	fclose(f);
 
-	if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-		mountlist_add(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-
 	cache_export_ent(exp->m_client->m_hostname, &exp->m_export);
 }
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index f40d367..97cd1a0 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -30,6 +30,7 @@
 extern void	cache_open(void);
 extern struct nfs_fh_len *cache_get_filehandle(nfs_export *exp, int len, char *p);
 extern void cache_export(nfs_export *exp);
+extern void cache_export_flush(char *domain, struct exportent *exp);
 
 extern void my_svc_run(void);
 
@@ -38,6 +39,7 @@ static exports		get_exportlist(void);
 static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, mountstat3 *, int v3);
 
 int new_cache = 0;
+int use_ip_address = 0;
 
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
@@ -66,6 +68,7 @@ static struct option longopts[] =
 	{ "ha-callout", 1, 0, 'H' },
 	{ "state-directory-path", 1, 0, 's' },
 	{ "num-threads", 1, 0, 't' },
+	{ "use-ip-addresses", 0, 0, 'I'},
 	{ NULL, 0, 0, 0 }
 };
 
@@ -226,11 +229,10 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *resp)
 		return 1;
 	}
 	if (new_cache) {
-		if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-			mountlist_del(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-		mountlist_del(exp->m_client->m_hostname, p);
+		cache_export_flush(exp->m_client->m_hostname,
+				   &exp->m_export);
 	} else {
-		mountlist_del(exp->m_client->m_hostname, p);
+		mountlist_del(exp->m_client->m_hostname, p, 0);
 		export_reset (exp);
 	}
 	return 1;
@@ -558,8 +560,11 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vs:t:", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "Io:nFd:f:p:P:hH:N:V:vs:t:", longopts, NULL)) != EOF)
 		switch (c) {
+		case 'I':
+			use_ip_address = 1;
+			break;
 		case 'o':
 			descriptors = atoi(optarg);
 			if (descriptors <= 0) {
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index d64c171..d62623c 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -46,7 +46,7 @@ nfs_export *	auth_authenticate(char *what, struct sockaddr_in *sin,
 void		auth_export(nfs_export *exp);
 
 void		mountlist_add(char *host, const char *path);
-void		mountlist_del(char *host, const char *path);
+void		mountlist_del(char *host, const char *path, int force);
 void		mountlist_del_all(struct sockaddr_in *sin);
 mountlist	mountlist_list(void);
 
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index f641a96..ab4c200 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -11,6 +11,7 @@
 #endif
 
 #include <sys/types.h>
+#include <time.h>
 #include <sys/stat.h>
 #include <unistd.h>
 #include <netinet/in.h>
@@ -89,7 +90,7 @@ mountlist_add(char *host, const char *path)
 }
 
 void
-mountlist_del(char *hname, const char *path)
+mountlist_del(char *hname, const char *path, int force)
 {
 	struct rmtabent	*rep;
 	FILE		*fp;
@@ -115,7 +116,7 @@ mountlist_del(char *hname, const char *path)
 			/* PRC: do the HA callout: */
 			ha_callout("unmount", rep->r_client, rep->r_path, rep->r_count);
 		}
-		if (!match || rep->r_count)
+		if (!match || (!force && rep->r_count))
 			fputrmtabent(fp, rep, NULL);
 	}
 	if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
@@ -200,6 +201,8 @@ mountlist_list(void)
 			xfree(m);
 		}
 		last_mtime = stb.st_mtime;
+		if (last_mtime == time(0))
+			last_mtime--;
 
 		setrmtabent("r");
 		while ((rep = getrmtabent(1, NULL)) != NULL) {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
