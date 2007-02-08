From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 06/12] Stop using storage after free
Date: Thu, 08 Feb 2007 17:27:19 -0500
Message-ID: <20070208222719.23464.48489.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk5-0006sg-LZ
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:49 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk7-0006nX-AX
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:51 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

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
---

 utils/idmapd/idmapd.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index cbb0b6a..b30b69e 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
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
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
