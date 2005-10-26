From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - rpc.idmapd - nfsdreopen still broken
Date: Wed, 26 Oct 2005 16:01:19 -0400
Message-ID: <435FE08F.50204@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060306000106080109070908"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUrSo-00060I-J8
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 13:01:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUrSn-0004NY-UQ
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 13:01:34 -0700
To: nfs@lists.sourceforge.net, Neil Brown <neilb@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------060306000106080109070908
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I've recently updated the nfs-utils in rawhide with the
latest patches from the SourceForge CVS tree and the
latest CITI patches (1.0.7-4).

In testing these patches, I notice that when the server was started
and a SIGHUP was sent to rpc.idmapd to open the nfs4.nametoid/channel
and nfs4.idtoname/channel files, the second open (the nfs4.idtoname one)
failed because the path (i.e. ic->ic_path) was NULL.

Now the reason the ic_path was NULL was because it was never set
during the call to nfsdopen(). nfsdopen() looks like:
nfsdopen(char *path)
{
     return ((nfsdopenone(&nfsd_ic[IC_NAMEID], IC_NAMEID, path) == 0 &&
             nfsdopenone(&nfsd_ic[IC_IDNAME], IC_IDNAME, path) == 0) ? 0 
: -1);
}

Note: the call to nfsdopenone() is how the path is set in each nfsd_ic[]
entry and nfsdopen() is only called once.

So when rpc.idmap comes up and the first call to nfsdopenone() fails
(because the server is not running) the path in nfsd_ic[IC_IDNAME] is
never filled in because the second nfsdopenone() never happen...

Now there was a CITI patche (idmapd_revert_fix_reopen_on_sighup.dif)
that tried to address this problem but did seem to fix it.. The
attached patch fix the problem by initializing both nfsd_ic[IC_IDNAME]
and nfsd_ic[IC_NAMEID] structures with the needed info...
I figured since there is no way of changing these paths or filenames
by command line args, why not just set them during compile time...
so that's what this patch does.

This patch also changes how nfsdreopen_one() handles the
case where the event has already been set. Unlike the CITI
patch (idmapd_revert_fix_reopen_on_sighup.dif) which just
just does not register the second event, my patch deletes
the old event and the registers the new one. It just seems like
the right thing to do since a SIGHUP means a new server just
started so we probably should create a new event as well...

steved.





--------------060306000106080109070908
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-idmapd-mapinit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-idmapd-mapinit.patch"

This patch initializes the paths in idmap_client structure used
by the server side which avoid the problem of this structure
not being initialized when a SIGHUP comes in.

This also changes nfsdreopen_one() to delete old events and register new ones
when its called with an event already registered. 

Signed-off by: Steve Dickson <steved@redhat.com>

------------------------
--- nfs-utils-1.0.7/utils/idmapd/idmapd.c.orig	2005-10-24 10:29:08.000000000 -0400
+++ nfs-utils-1.0.7/utils/idmapd/idmapd.c	2005-10-24 10:32:13.000000000 -0400
@@ -94,18 +94,28 @@
 } while (0)
 
 #define IC_IDNAME 0
+#define IC_IDNAME_CHAN  NFSD_DIR "/nfs4.idtoname/channel"
+#define IC_IDNAME_FLUSH NFSD_DIR "/nfs4.idtoname/flush"
+
 #define IC_NAMEID 1
+#define IC_NAMEID_CHAN  NFSD_DIR "/nfs4.nametoid/channel"
+#define IC_NAMEID_FLUSH NFSD_DIR "/nfs4.nametoid/flush"
+
 struct idmap_client {
-	int                        ic_fd;
-	int                        ic_dirfd;
+	short                      ic_which;
 	char                       ic_clid[30];
+	char                      *ic_id;
 	char                       ic_path[PATH_MAX];
+	int                        ic_fd;
+	int                        ic_dirfd;
 	int                        ic_scanned;
 	struct event               ic_event;
-	char                      *ic_id;
-	short                      ic_which;
 	TAILQ_ENTRY(idmap_client)  ic_next;
 };
+static struct idmap_client nfsd_ic[2] = {
+{IC_IDNAME, "Server", "", IC_IDNAME_CHAN, -1, -1, 0},
+{IC_NAMEID, "Server", "", IC_NAMEID_CHAN, -1, -1, 0},
+};
 
 TAILQ_HEAD(idmap_clientq, idmap_client);
 
@@ -138,7 +148,6 @@ static char pipefsdir[PATH_MAX];
 static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
-static struct idmap_client nfsd_ic[2];
 
 /* Used by cfg.c */
 char *conf_path;
@@ -164,10 +173,10 @@ flush_nfsd_idmap_cache(void)
 	time_t now = time(NULL);
 	int ret;
 
-	ret = flush_nfsd_cache("/proc/net/rpc/nfs4.idtoname/flush", now);
+	ret = flush_nfsd_cache(IC_IDNAME_FLUSH, now);
 	if (ret)
 		return ret;
-	ret = flush_nfsd_cache("/proc/net/rpc/nfs4.nametoid/flush", now);
+	ret = flush_nfsd_cache(IC_NAMEID_FLUSH, now);
 	return ret;
 }
 
@@ -675,9 +684,13 @@ nfsdreopen_one(struct idmap_client *ic)
 
 	if (verbose > 0)
 		idmapd_warnx("ReOpening %s", ic->ic_path);
+
 	if ((fd = open(ic->ic_path, O_RDWR, 0)) != -1) {
 		if (ic->ic_fd != -1)
 			close(ic->ic_fd);
+		if ((ic->ic_event.ev_flags & EVLIST_INIT))
+			event_del(&ic->ic_event);
+
 		ic->ic_event.ev_fd = ic->ic_fd = fd;
 		event_set(&ic->ic_event, ic->ic_fd, EV_READ, nfsdcb, ic);
 		event_add(&ic->ic_event, NULL);
@@ -687,9 +700,6 @@ nfsdreopen_one(struct idmap_client *ic)
 	}
 }
 
-/*
- * Note: nfsdreopen assumes nfsdopen has already been called
- */
 static void
 nfsdreopen()
 {
@@ -710,9 +720,6 @@ nfsdopenone(struct idmap_client *ic, sho
 {
 	char *whichstr;
 
-	whichstr = which == IC_IDNAME ? "idtoname" : "nametoid";
-	snprintf(ic->ic_path, sizeof(ic->ic_path),
-		"%s/nfs4.%s/channel", path, whichstr);
 	if ((ic->ic_fd = open(ic->ic_path, O_RDWR, 0)) == -1) {
 		if (verbose > 0)
 			idmapd_warnx("Opening %s failed: errno %d (%s)",
@@ -723,10 +730,6 @@ nfsdopenone(struct idmap_client *ic, sho
 	event_set(&ic->ic_event, ic->ic_fd, EV_READ, nfsdcb, ic);
 	event_add(&ic->ic_event, NULL);
 
-	ic->ic_which = which;
-	ic->ic_id = "Server";
-	strlcpy(ic->ic_clid, "Server", strlen("Server"));
-
 	if (verbose > 0)
 		idmapd_warnx("Opened %s", ic->ic_path);
 

--------------060306000106080109070908--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
