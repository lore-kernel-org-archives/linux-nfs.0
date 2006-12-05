From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Mon, 04 Dec 2006 21:51:37 -0500
Message-ID: <4574DEB9.1060004@redhat.com>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>	<45704A4A.6000007@poochiereds.net>	<17779.42545.642976.873602@cse.unsw.edu.au>	<17779.49460.590066.210744@cse.unsw.edu.au>
	<4574D964.8070504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrQPJ-00020B-Lh
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 18:51:45 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GrQPJ-0001xZ-Pw
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 18:51:46 -0800
To: neilb@suse.de
In-Reply-To: <4574D964.8070504@redhat.com>
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

Jeff Layton wrote:
> Neil Brown wrote:
>  > It tries a bit harder to keep vaguely sensible information in rmtab
>  > and if you run mounted with "-I", then "showmount -a" will list IP and
>  > export-point of all current mounts ... as best as possible.
>  > e.g. if you mount the same filesystem twice on the one client, then it
>  > will appear once in "showmount -a".  If you then unmount one of them,
>  > it will disappear.  But as soon as you access it again it will
>  > re-appear.
>  >
>  > I think this is about the best I can do.
>  >
>  > Does it meet the needs?
>  >
>
> I think we need to fix the default case here instead of adding a
> workaround flag. We should also strive to make it report hostnames
> rather than ip addresses if possible. I don't see a need for the -I flag
> here.
>
> How about this patch instead? It combines some of my earlier patches
> with the one you just proposed.  I did some very cursory testing and it
> seems to work correctly, populating rmtab with hostname:/path instead of
> ipaddr:/path.
>

Apologies, my mailer munged that last patch. Here it is again...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/support/export/client.c.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/support/export/client.c	2006-12-04 20:33:51.000000000 -0500
@@ -234,102 +234,15 @@
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
-
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
--- nfs-utils-1.0.10/support/include/exportfs.h.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/support/include/exportfs.h	2006-12-04 20:38:46.000000000 -0500
@@ -55,8 +55,7 @@
  int				client_match(nfs_client *, char *hname);
  void				client_release(nfs_client *);
  void				client_freeall(void);
-char *				client_compose(struct in_addr addr);
-int 				client_member(char *client, char *name);
+struct hostent *		client_resolve(struct in_addr addr);

  int				export_read(char *fname);
  void				export_add(nfs_export *);
--- nfs-utils-1.0.10/utils/mountd/auth.c.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/utils/mountd/auth.c	2006-12-04 20:33:51.000000000 -0500
@@ -76,27 +76,16 @@
  	if (new_cache) {
  		int i;
  		/* return static nfs_export with details filled in */
-		if (my_client.m_naddr != 1 ||
-		    my_client.m_addrlist[0].s_addr != caller->sin_addr.s_addr) {
-			/* different client to last time, so do a lookup */
-			char *n;
-			my_client.m_naddr = 0;
-			my_client.m_addrlist[0] = caller->sin_addr;
-			n = client_compose(caller->sin_addr);
-			*error = unknown_host;
-			if (!n)
-				return NULL;
-			strcpy(my_client.m_hostname, *n?n:"DEFAULT");
-			free(n);
-			my_client.m_naddr = 1;
-		}
-
+		my_client.m_addrlist[0] = caller->sin_addr;
+		my_client.m_naddr = 1;
+		strncpy(my_client.m_hostname, hp->h_name,
+			sizeof(my_client.m_hostname));
  		my_exp.m_client = &my_client;

  		exp = NULL;
  		for (i = 0; !exp && i < MCL_MAXTYPES; i++)
  			for (exp = exportlist[i]; exp; exp = exp->m_next) {
-				if (!client_member(my_client.m_hostname, exp->m_client->m_hostname))
+				if (!client_check(exp->m_client, hp))
  					continue;
  				if (strcmp(path, exp->m_export.e_path))
  					continue;
--- nfs-utils-1.0.10/utils/mountd/cache.c.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/utils/mountd/cache.c	2006-12-04 20:37:24.000000000 -0500
@@ -53,8 +53,8 @@
  	char *cp;
  	char class[20];
  	char ipaddr[20];
-	char *client;
  	struct in_addr addr;
+	struct hostent *he;
  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
  		return;

@@ -73,21 +73,16 @@
  	auth_reload();

  	/* addr is a valid, interesting address, find the domain name... */
-	client = client_compose(addr);
+	he = client_resolve(addr);

-	
  	qword_print(f, "nfsd");
  	qword_print(f, ipaddr);
  	qword_printint(f, time(0)+30*60);
-	if (client)
-		qword_print(f, *client?client:"DEFAULT");
+	if (he) {
+		qword_print(f, *he->h_name?he->h_name:"DEFAULT");
+		free(he);
+	}
  	qword_eol(f);
-
-	if (client && strcmp(ipaddr, client))
-		mountlist_add(ipaddr, *client?client:"DEFAULT");
-
-	if (client) free(client);
-	
  }

  void nfsd_fh(FILE *f)
@@ -109,6 +104,7 @@
  	nfs_export *exp;
  	int i;
  	int dev_missing = 0;
+	struct hostent *hp = NULL;

  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
  		return;
@@ -170,11 +166,12 @@
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
@@ -251,6 +248,7 @@
  	int i;
  	char *dom, *path;
  	nfs_export *exp, *found = NULL;
+	struct hostent *hp;


  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
@@ -271,9 +269,10 @@
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
@@ -377,6 +376,23 @@
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
@@ -393,9 +409,6 @@
  	
  	fclose(f);

-	if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-		mountlist_add(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-
  	cache_export_ent(exp->m_client->m_hostname, &exp->m_export);
  }

--- nfs-utils-1.0.10/utils/mountd/mountd.c.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/utils/mountd/mountd.c	2006-12-04 20:33:51.000000000 -0500
@@ -30,6 +30,7 @@
  extern void	cache_open(void);
  extern struct nfs_fh_len *cache_get_filehandle(nfs_export *exp, int len, char *p);
  extern void cache_export(nfs_export *exp);
+extern void cache_export_flush(char *domain, struct exportent *exp);

  extern void my_svc_run(void);

@@ -226,11 +227,10 @@
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
--- nfs-utils-1.0.10/utils/mountd/mountd.h.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/utils/mountd/mountd.h	2006-12-04 20:33:51.000000000 -0500
@@ -46,7 +46,7 @@
  void		auth_export(nfs_export *exp);

  void		mountlist_add(char *host, const char *path);
-void		mountlist_del(char *host, const char *path);
+void		mountlist_del(char *host, const char *path, int force);
  void		mountlist_del_all(struct sockaddr_in *sin);
  mountlist	mountlist_list(void);

--- nfs-utils-1.0.10/utils/mountd/rmtab.c.rmtab	2006-08-07 02:40:50.000000000 -0400
+++ nfs-utils-1.0.10/utils/mountd/rmtab.c	2006-12-04 20:33:51.000000000 -0500
@@ -11,6 +11,7 @@
  #endif

  #include <sys/types.h>
+#include <time.h>
  #include <sys/stat.h>
  #include <unistd.h>
  #include <netinet/in.h>
@@ -89,7 +90,7 @@
  }

  void
-mountlist_del(char *hname, const char *path)
+mountlist_del(char *hname, const char *path, int force)
  {
  	struct rmtabent	*rep;
  	FILE		*fp;
@@ -115,7 +116,7 @@
  			/* PRC: do the HA callout: */
  			ha_callout("unmount", rep->r_client, rep->r_path, rep->r_count);
  		}
-		if (!match || rep->r_count)
+		if (!match || (!force && rep->r_count))
  			fputrmtabent(fp, rep, NULL);
  	}
  	if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
@@ -200,6 +201,8 @@
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
