From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] idmapd: plug memory leak in dirscancb
Date: Thu, 26 Oct 2006 14:43:41 -0400
Message-ID: <1161888221.2667.40.camel@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdACq-0003by-8p
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:43:56 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdACp-00034N-V7
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:43:57 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9QIhlaI011230
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:43:47 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9QIhlrj030978
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:43:47 -0400
Received: from tleilax.poochiereds.net (vpn-14-145.rdu.redhat.com
	[10.11.14.145])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id k9QIhgvi005100
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:43:43 -0400
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

There is a pretty nasty memory leak in idmapd in dirscancb(). Some of
our customers have reported that idmapd can eat gigabytes of memory on
machines with a large number of mounts and unmounts and a long uptime.

That function uses scandir(), which malloc's an array of strings, but
dirscancb() never frees the strings or the array. The following patch
should correct this, but I've not yet tested it on 1.0.10 (only on the
RHEL4 1.0.6 version). Still, the code is very similar and I'm fairly
certain the problem exists in both versions.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/idmapd/idmapd.c.leak
+++ nfs-utils-1.0.10/utils/idmapd/idmapd.c
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
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
