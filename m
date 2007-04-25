From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Wed, 25 Apr 2007 14:09:34 -0400
Message-ID: <20070425180932.GC6696@salusa.poochiereds.net>
References: <20070425173918.GB6696@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hglvq-0000oc-F4
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 11:09:34 -0700
Received: from ms-smtp-01.southeast.rr.com ([24.25.9.100])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hglvs-0003FA-LD
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 11:09:37 -0700
Received: from mail.poochiereds.net (cpe-071-070-159-068.nc.res.rr.com
	[71.70.159.68])
	by ms-smtp-01.southeast.rr.com (8.13.6/8.13.6) with ESMTP id
	l3PI9YK8005668
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 14:09:35 -0400 (EDT)
In-Reply-To: <20070425173918.GB6696@salusa.poochiereds.net>
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

On Wed, Apr 25, 2007 at 01:39:20PM -0400, Jeff Layton wrote:
> Currently, when auth_reload is called, it only looks at the tv_sec field
> of the mtime when deciding whether to invalidate the exports cache. It's
> fairly simple to fool this by doing something like:
> 
> # exportfs -rv && rpc.mountd && exportfs -uva && exportfs -iv -o no_root_squash,rw 127.0.0.1:/foo
> 
> With this, exportfs will show the export for /foo, but mountd will still have
> whatever contents were in /etc/exports. The issue is that the etab is being
> updated twice during the same second, and mountd is reading in the file in
> between updates. When it goes to look at the file again, its timestamp matches
> the timestamp of the cache, and it ends up keeping the cached contents even
> though the file has changed.
> 
> While not all local filesystems provide sub-second timestamps, we might as
> well fix this problem on those that do. The following patch changes
> auth_reload to consider the tv_nsec field of the mtime when deciding whether
> to invalidate the export cache. It also fixes up the callers to pass it a
> pointer to a struct timespec for it to fill out.
> 
> I've not yet tested this on a filesystem that provides sub-second timestamps,
> so I'm not clear on how well this works yet, but it seems to not break
> anything on ext3 in some cursory testing.
> 

No sooner than I post than I see a (minor) problem. The check for a NULL
pointer in auth_reload should be (ts != NULL) instead of (ts). Respun patch
follows:

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 183c9ea..274e560 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -42,28 +42,34 @@ auth_init(char *exports)
 {
 
 	export_file = exports;
-	auth_reload();
+	auth_reload(NULL);
 	xtab_mount_write();
 }
 
-time_t
-auth_reload()
+void
+auth_reload(struct timespec *ts)
 {
 	struct stat		stb;
-	static time_t		last_modified = 0;
+	static struct timespec	last_modified;
 
 	if (stat(_PATH_ETAB, &stb) < 0)
 		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
-	if (stb.st_mtime == last_modified)
-		return last_modified;
-	last_modified = stb.st_mtime;
+	if (stb.st_mtim.tv_sec == last_modified.tv_sec &&
+	    stb.st_mtim.tv_nsec == last_modified.tv_nsec)
+		goto out;
 
+	last_modified.tv_sec = stb.st_mtim.tv_sec;
+	last_modified.tv_nsec = stb.st_mtim.tv_nsec;
 	export_freeall();
 	memset(&my_client, 0, sizeof(my_client));
 	// export_read(export_file);
 	xtab_export_read();
-
-	return last_modified;
+out:
+	if (ts != NULL) {
+		ts->tv_sec = stb.st_mtim.tv_sec;
+		ts->tv_nsec = stb.st_mtim.tv_nsec;
+	}
+	return;
 }
 
 static nfs_export *
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d068843..77c559f 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -90,7 +90,7 @@ void auth_unix_ip(FILE *f)
 	if (inet_aton(ipaddr, &addr)==0)
 		return;
 
-	auth_reload();
+	auth_reload(NULL);
 
 	/* addr is a valid, interesting address, find the domain name... */
 	client = client_compose(addr);
@@ -354,7 +354,7 @@ void nfsd_fh(FILE *f)
 		break;
 	}
 
-	auth_reload();
+	auth_reload(NULL);
 
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
@@ -575,7 +575,7 @@ void nfsd_export(FILE *f)
 	if (qword_get(&cp, path, strlen(lbuf)) <= 0)
 		goto out;
 
-	auth_reload();
+	auth_reload(NULL);
 
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 04141d1..96d25a1 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -241,7 +241,7 @@ bool_t
 mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
 {
 	/* Reload /etc/xtab if necessary */
-	auth_reload();
+	auth_reload(NULL);
 
 	mountlist_del_all((struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt));
 	return 1;
@@ -299,7 +299,7 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 		p = "/";
 
 	/* Reload /etc/xtab if necessary */
-	auth_reload();
+	auth_reload(NULL);
 
 	/* Resolve symlinks */
 	if (realpath(p, rpath) != NULL) {
@@ -373,7 +373,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
 		p = "/";
 
 	/* Reload /var/lib/nfs/etab if necessary */
-	auth_reload();
+	auth_reload(NULL);
 
 	/* Resolve symlinks */
 	if (realpath(p, rpath) != NULL) {
@@ -465,18 +465,20 @@ static exports
 get_exportlist(void)
 {
 	static exports		elist = NULL;
-	static time_t		etime = 0;
-	time_t			atime;
+	static struct timespec	etime;
+	struct timespec		atime;
 	struct exportnode	*e, *ne;
 	struct groupnode	*g, *ng, *c, **cp;
 	nfs_export		*exp;
 	int			i;
 
-	atime = auth_reload();
-	if (elist && atime == etime)
+	auth_reload(&atime);
+	if (elist && atime.tv_sec == etime.tv_sec &&
+	    atime.tv_nsec == etime.tv_nsec)
 		return elist;
 
-	etime = atime;
+	etime.tv_sec = atime.tv_sec;
+	etime.tv_nsec = atime.tv_nsec;
 
 	for (e = elist; e != NULL; e = ne) {
 		ne = e->ex_next;
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index b539278..58694d9 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -40,7 +40,7 @@ bool_t		mount_mnt_3_svc(struct svc_req *, dirpath *, mountres3 *);
 
 void		mount_dispatch(struct svc_req *, SVCXPRT *);
 void		auth_init(char *export_file);
-time_t		auth_reload(void);
+void 		auth_reload(struct timespec *ts);
 nfs_export *	auth_authenticate(char *what, struct sockaddr_in *sin,
 					char *path);
 void		auth_export(nfs_export *exp);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
