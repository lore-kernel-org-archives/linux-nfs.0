From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 3 May 2007 08:11:09 -0400
Message-ID: <20070503121108.GB4641@dantu.rdu.redhat.com>
References: <462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
	<20070426120536.GB24800@dantu.rdu.redhat.com>
	<20070426162300.GA12193@salusa.poochiereds.net>
	<20070426165800.GC4875@fieldses.org>
	<20070426170055.GA30402@dantu.rdu.redhat.com>
	<20070426172444.GE4875@fieldses.org>
	<20070426182901.GA31081@dantu.rdu.redhat.com>
	<17977.13065.307535.484372@notabene.brown>
	<20070503115814.GA4641@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hja9N-0008Up-UK
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 05:11:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hja9Q-0000mA-17
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 05:11:12 -0700
In-Reply-To: <20070503115814.GA4641@dantu.rdu.redhat.com>
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

On Thu, May 03, 2007 at 07:58:15AM -0400, Jeff Layton wrote:
> On Thu, May 03, 2007 at 10:55:37AM +1000, Neil Brown wrote:
> > On Thursday April 26, jlayton@redhat.com wrote:
> > > 
> > > This patch seems to fix the problem as well. mountd holds the etab open, but
> > > doesn't actually do any I/O on that fd. This makes sure that the inode number
> > > of the new etab file won't be the same as the current version that mountd is
> > > aware of. I also added a comment to xtab_write to warn people who might
> > > consider changing how the files are written.
> > > 
> > > We might also consider adding back in some of the mtime logic to try and
> > > catch programs that edit the file in place, but I'm not sure if that's
> > > worthwhile.
> > 
> > I agree.
> > 
> > > 
> > > Neil, what do you think?
> > 
> > I was about to say "fine", but then saw the problem.
> > Because of the way get_exportlist uses the return value, that value
> > needs to unique over all time (or close to it).  So returning the
> > inode number won't work (as we have seen that ext3 cycles between
> > two).
> > 
> > A simple event counter could be returned though, which would give
> > something unique to get_exportlist.
> > 
> > NeilBrown
> 
> Ahh, good catch. I wasn't considering that mountd might call into auth_reload
> from other functions between get_exportlist calls. I'm not sure we even really
> need a static counter here though. How about just having auth_reload return
> true if the reload occurred?
> 

Doh! That won't work for the same reason. Static counter it is...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

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
index 183c9ea..f7fe23d 100644
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
@@ -46,24 +47,34 @@ auth_init(char *exports)
 	xtab_mount_write();
 }
 
-time_t
+unsigned int
 auth_reload()
 {
 	struct stat		stb;
-	static time_t		last_modified = 0;
-
-	if (stat(_PATH_ETAB, &stb) < 0)
+	static ino_t		last_inode;
+	static int		last_fd;
+	static unsigned int	counter;
+	int			fd;
+
+	if ((fd = open(_PATH_ETAB, O_RDONLY)) < 0) {
+		xlog(L_FATAL, "couldn't open %s", _PATH_ETAB);
+	} else if (fstat(fd, &stb) < 0) {
 		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
-	if (stb.st_mtime == last_modified)
-		return last_modified;
-	last_modified = stb.st_mtime;
+	} else if (stb.st_ino == last_inode) {
+		close(fd);
+		return counter;
+	} else {
+		close(last_fd);
+		last_fd = fd;
+		last_inode = stb.st_ino;
+	}
 
 	export_freeall();
 	memset(&my_client, 0, sizeof(my_client));
-	// export_read(export_file);
 	xtab_export_read();
+	++counter;
 
-	return last_modified;
+	return counter;
 }
 
 static nfs_export *
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 04141d1..999f035 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -465,18 +465,18 @@ static exports
 get_exportlist(void)
 {
 	static exports		elist = NULL;
-	static time_t		etime = 0;
-	time_t			atime;
 	struct exportnode	*e, *ne;
 	struct groupnode	*g, *ng, *c, **cp;
 	nfs_export		*exp;
 	int			i;
+	static unsigned int	ecounter;
+	unsigned int		acounter;
 
-	atime = auth_reload();
-	if (elist && atime == etime)
+	acounter = auth_reload();
+	if (elist && acounter == ecounter)
 		return elist;
 
-	etime = atime;
+	ecounter = acounter;
 
 	for (e = elist; e != NULL; e = ne) {
 		ne = e->ex_next;
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index b539278..31bacb5 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -40,7 +40,7 @@ bool_t		mount_mnt_3_svc(struct svc_req *, dirpath *, mountres3 *);
 
 void		mount_dispatch(struct svc_req *, SVCXPRT *);
 void		auth_init(char *export_file);
-time_t		auth_reload(void);
+unsigned int	auth_reload(void);
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
