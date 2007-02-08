From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 05/12] Fix memory leak in idmapd.
Date: Thu, 08 Feb 2007 17:27:14 -0500
Message-ID: <20070208222714.23464.2972.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk4-0006sS-Qb
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:48 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFHk6-0004Pd-Hq
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:50 -0800
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

There is a pretty nasty memory leak in idmapd in dirscancb(). Some of
our customers have reported that idmapd can eat gigabytes of memory on
machines with a large number of mounts and unmounts and a long uptime.

That function uses scandir(), which malloc's an array of strings, but
dirscancb() never frees the strings or the array. The following patch
should correct this, but I've not yet tested it on 1.0.10 (only on the
RHEL4 1.0.6 version). Still, the code is very similar and I'm fairly
certain the problem exists in both versions.
---

 utils/idmapd/idmapd.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 19bf7a6..cbb0b6a 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -464,7 +464,7 @@ dirscancb(int fd, short which, void *dat
 				goto next;
 
 			if ((ic = calloc(1, sizeof(*ic))) == NULL)
-				return;
+				goto out;
 			strlcpy(ic->ic_clid, ents[i]->d_name + 4,
 			    sizeof(ic->ic_clid));
 			path[0] = '\0';
@@ -474,7 +474,7 @@ dirscancb(int fd, short which, void *dat
 			if ((ic->ic_dirfd = open(path, O_RDONLY, 0)) == -1) {
 				idmapd_warn("dirscancb: open(%s)", path);
 				free(ic);
-				return;
+				goto out;
 			}
 
 			strlcat(path, "/idmap", sizeof(path));
@@ -486,7 +486,7 @@ dirscancb(int fd, short which, void *dat
 			if (nfsopen(ic) == -1) {
 				close(ic->ic_dirfd);
 				free(ic);
-				return;
+				goto out;
 			}
 
 			ic->ic_id = "Client";
@@ -512,6 +512,11 @@ dirscancb(int fd, short which, void *dat
 		} else
 			ic->ic_scanned = 0;
 	}
+
+out:
+	for (i = 0;  i < nent; i++)
+		free(ents[i]);
+	free(ents);
 	return;
 }
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
