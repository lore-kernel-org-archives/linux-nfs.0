From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] idmapd: fix use after free in dirscancb cleanup
	loop
Date: Thu, 26 Oct 2006 14:45:39 -0400
Message-ID: <1161888339.2667.44.camel@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdAEk-0003oH-Gg
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:45:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdAEi-0006sJ-Ar
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:45:55 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9QIjkrN012533
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:45:46 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9QIjjPL031902
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:45:45 -0400
Received: from tleilax.poochiereds.net (vpn-14-145.rdu.redhat.com
	[10.11.14.145])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id k9QIjdEC005682
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:45:40 -0400
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

The previous patch seems to expose a use after free bug in dirscancb. At
least, I could reliably reproduce a segfault by doing a bunch of mounts
and then unmounting them all. The code uses the following list macro:

      TAILQ_FOREACH(ic, icq, ic_next) {

...to iterate over all of the ic entries and clean up any that no longer
have a corresponding directory in rpc_pipefs. This macro unrolls into:

      for(ic=icq->tqh_first; ic != NULL; ic=ic->ic_next.tqe_next) {

...but within this loop, we can free ic, and then the for loop can trip
over that when it tries to do the iteration. The attached patch works
around this by not using the TAILQ_FOREACH macro and saving off the
tqe_next pointer prior to the free.

Again, this was tested on a patched 1.0.6, but the 1.0.10 code is very
similar, and I think the problem exists there as well.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/idmapd/idmapd.c.segv
+++ nfs-utils-1.0.10/utils/idmapd/idmapd.c
@@ -444,7 +444,7 @@ dirscancb(int fd, short which, void *dat
 {
 	int nent, i;
 	struct dirent **ents;
-	struct idmap_client *ic;
+	struct idmap_client *ic, *nextic;
 	char path[PATH_MAX];
 	struct idmap_clientq *icq = data;
 
@@ -498,7 +498,9 @@ dirscancb(int fd, short which, void *dat
 		}
 	}
 
-	TAILQ_FOREACH(ic, icq, ic_next) {
+	ic = TAILQ_FIRST(icq);
+	while(ic != NULL) {
+		nextic=TAILQ_NEXT(ic, ic_next);
 		if (!ic->ic_scanned) {
 			event_del(&ic->ic_event);
 			close(ic->ic_fd);
@@ -511,6 +513,7 @@ dirscancb(int fd, short which, void *dat
 			free(ic);
 		} else
 			ic->ic_scanned = 0;
+		ic = nextic;
 	}
 
 out:



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
