From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 26 Apr 2007 14:29:02 -0400
Message-ID: <20070426182901.GA31081@dantu.rdu.redhat.com>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
	<20070426120536.GB24800@dantu.rdu.redhat.com>
	<20070426162300.GA12193@salusa.poochiereds.net>
	<20070426165800.GC4875@fieldses.org>
	<20070426170055.GA30402@dantu.rdu.redhat.com>
	<20070426172444.GE4875@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh8iI-0007I4-Lr
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 11:29:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh8iK-0000nh-NU
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 11:29:09 -0700
In-Reply-To: <20070426172444.GE4875@fieldses.org>
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

On Thu, Apr 26, 2007 at 01:24:44PM -0400, J. Bruce Fields wrote:
> On Thu, Apr 26, 2007 at 01:00:56PM -0400, Jeff Layton wrote:
> > Not if the inode number is reused. That can occur on some filesystems if
> > nothing is holding it open. Then again, if we're opening a new file and
> > renaming it to the old name, then that might not be an issue here. Let me
> > play with that idea and see...
> 
> Hm.  Grepping around: I didn't realize ext2/3/4 seem to have a
> GETVERSION ioctl that returns the generation number.  But I don't know
> if there's any more filesystem-independent way to do that.
> 
> (Is there some better way?  I don't understand why people would work so
> hard on change notification without having a simple way to poll for
> changes as well--otherwise you lose track of everything the moment the
> watcher goes away, and you end up with beagle having to reread your
> entire filesystem after every reboot.)
> 
> --b.

I hadn't considered using the inode generation, but I'm not sure that that
will be portable enough. I think though, that Neil's plan of holding the
inode open may work ok.

This patch seems to fix the problem as well. mountd holds the etab open, but
doesn't actually do any I/O on that fd. This makes sure that the inode number
of the new etab file won't be the same as the current version that mountd is
aware of. I also added a comment to xtab_write to warn people who might
consider changing how the files are written.

We might also consider adding back in some of the mtime logic to try and
catch programs that edit the file in place, but I'm not sure if that's
worthwhile.

Neil, what do you think?

-- Jeff


diff --git a/support/export/xtab.c b/support/export/xtab.c
index 0ddb251..292087b 100644
--- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -80,6 +80,12 @@ xtab_export_read(void)
 	return xtab_read(_PATH_ETAB, 1);
 }
 
+/*
+ * mountd now keeps an open fd for the etab at all times to make sure that the
+ * inode number changes when the xtab_export_write is done. If you change the
+ * routine below such that the files are edited in place, then you'll need to
+ * fix the auth_reload logic as well...
+ */
 static int
 xtab_write(char *xtab, char *xtabtmp, int is_export)
 {
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 183c9ea..a0a034d 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -14,6 +14,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <errno.h>
+#include <unistd.h>
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -46,24 +47,32 @@ auth_init(char *exports)
 	xtab_mount_write();
 }
 
-time_t
+ino_t
 auth_reload()
 {
 	struct stat		stb;
-	static time_t		last_modified = 0;
+	static ino_t		last_inode;
+	static int		last_fd;
+	int			fd;
 
-	if (stat(_PATH_ETAB, &stb) < 0)
+	if ((fd = open(_PATH_ETAB, O_RDONLY)) < 0) {
+		xlog(L_FATAL, "couldn't open %s", _PATH_ETAB);
+	} else if (fstat(fd, &stb) < 0) {
 		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
-	if (stb.st_mtime == last_modified)
-		return last_modified;
-	last_modified = stb.st_mtime;
+	} else if (stb.st_ino == last_inode) {
+		close(fd);
+		return last_inode;
+	} else {
+		close(last_fd);
+		last_fd = fd;
+		last_inode = stb.st_ino;
+	}
 
 	export_freeall();
 	memset(&my_client, 0, sizeof(my_client));
-	// export_read(export_file);
 	xtab_export_read();
 
-	return last_modified;
+	return last_inode;
 }
 
 static nfs_export *
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 04141d1..eea8483 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -465,18 +465,18 @@ static exports
 get_exportlist(void)
 {
 	static exports		elist = NULL;
-	static time_t		etime = 0;
-	time_t			atime;
+	static ino_t		einode;
+	ino_t			ainode;
 	struct exportnode	*e, *ne;
 	struct groupnode	*g, *ng, *c, **cp;
 	nfs_export		*exp;
 	int			i;
 
-	atime = auth_reload();
-	if (elist && atime == etime)
+	ainode = auth_reload();
+	if (elist && ainode == einode)
 		return elist;
 
-	etime = atime;
+	einode = ainode;
 
 	for (e = elist; e != NULL; e = ne) {
 		ne = e->ex_next;
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index b539278..4e507e6 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -40,7 +40,7 @@ bool_t		mount_mnt_3_svc(struct svc_req *, dirpath *, mountres3 *);
 
 void		mount_dispatch(struct svc_req *, SVCXPRT *);
 void		auth_init(char *export_file);
-time_t		auth_reload(void);
+ino_t		auth_reload(void);
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
