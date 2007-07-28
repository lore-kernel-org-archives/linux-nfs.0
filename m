From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/23] mount.nfs: fix printf's normally hidden
	behind	NFS_MOUNT_DEBUG
Date: Sat, 28 Jul 2007 17:49:18 -0400
Message-ID: <20070728214918.21871.38740.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAy-0007Z2-6R
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:16 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuB1-0003aK-Qc
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:20 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

After I enabled NFS_MOUNT_DEBUG the compiler started spitting out warnings.
Fix up commas, output formatting, and double-wide character support.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs4mount.c |   19 ++++++++++---------
 utils/mount/nfsmount.c  |   25 ++++++++++++-------------
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index bd20864..4868c08 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -367,14 +367,14 @@ int nfs4mount(const char *spec, const char *node, int flags,
 	data.host_addrlen = sizeof(server_addr);
 
 #ifdef NFS_MOUNT_DEBUG
-	printf("rsize = %d, wsize = %d, timeo = %d, retrans = %d\n",
+	printf(_("rsize = %d, wsize = %d, timeo = %d, retrans = %d\n"),
 	       data.rsize, data.wsize, data.timeo, data.retrans);
-	printf("acreg (min, max) = (%d, %d), acdir (min, max) = (%d, %d)\n",
+	printf(_("acreg (min, max) = (%d, %d), acdir (min, max) = (%d, %d)\n"),
 	       data.acregmin, data.acregmax, data.acdirmin, data.acdirmax);
-	printf("port = %d, bg = %d, retry = %d, flags = %.8x\n",
+	printf(_("port = %d, bg = %d, retry = %d, flags = %.8x\n"),
 	       ntohs(server_addr.sin_port), bg, retry, data.flags);
-	printf("soft = %d, intr = %d, nocto = %d, noac = %d, "
-	       "nosharecache = %d\n",
+	printf(_("soft = %d, intr = %d, nocto = %d, noac = %d, "
+	       "nosharecache = %d\n"),
 	       (data.flags & NFS4_MOUNT_SOFT) != 0,
 	       (data.flags & NFS4_MOUNT_INTR) != 0,
 	       (data.flags & NFS4_MOUNT_NOCTO) != 0,
@@ -384,18 +384,19 @@ int nfs4mount(const char *spec, const char *node, int flags,
 	if (num_flavour > 0) {
 		int pf_cnt, i;
 
-		printf("sec = ");
+		printf(_("sec = "));
 		for (pf_cnt = 0; pf_cnt < num_flavour; pf_cnt++) {
 			for (i = 0; i < flav_map_size; i++) {
 				if (flav_map[i].fnum == pseudoflavour[pf_cnt]) {
-					printf("%s", flav_map[i].flavour);
+					printf(_("%s"), flav_map[i].flavour);
 					break;
 				}
 			}
-			printf("%s", (pf_cnt < num_flavour-1) ? ":" : "\n");
+			printf(_("%s"),
+				(pf_cnt < num_flavour - 1) ?  _(":") : _("\n"));
 		}
 	}
-	printf("proto = %s\n", (data.proto == IPPROTO_TCP) ? "tcp" : "udp");
+	printf(_("proto = %s\n"), (data.proto == IPPROTO_TCP) ? _("tcp") : _("udp"));
 #endif
 
 	timeout = time(NULL) + 60 * retry;
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index ac8d161..a2b95ad 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -582,36 +582,35 @@ nfsmount(const char *spec, const char *node, int flags,
 	
 	if (retry == 10000 && !bg)
 		retry = 2; /* reset for fg mounts */
-	
 
 #ifdef NFS_MOUNT_DEBUG
-	printf("rsize = %d, wsize = %d, timeo = %d, retrans = %d\n",
+	printf(_("rsize = %d, wsize = %d, timeo = %d, retrans = %d\n"),
 	       data.rsize, data.wsize, data.timeo, data.retrans);
-	printf("acreg (min, max) = (%d, %d), acdir (min, max) = (%d, %d)\n",
+	printf(_("acreg (min, max) = (%d, %d), acdir (min, max) = (%d, %d)\n"),
 	       data.acregmin, data.acregmax, data.acdirmin, data.acdirmax);
-	printf("port = %d, bg = %d, retry = %d, flags = %.8x\n",
+	printf(_("port = %lu, bg = %d, retry = %d, flags = %.8x\n"),
 	       nfs_pmap->pm_port, bg, retry, data.flags);
-	printf("mountprog = %d, mountvers = %d, nfsprog = %d, nfsvers = %d\n",
+	printf(_("mountprog = %lu, mountvers = %lu, nfsprog = %lu, nfsvers = %lu\n"),
 	       mnt_pmap->pm_prog, mnt_pmap->pm_vers,
 	       nfs_pmap->pm_prog, nfs_pmap->pm_vers);
-	printf("soft = %d, intr = %d, posix = %d, nocto = %d, noac = %d ",
+	printf(_("soft = %d, intr = %d, posix = %d, nocto = %d, noac = %d"),
 	       (data.flags & NFS_MOUNT_SOFT) != 0,
 	       (data.flags & NFS_MOUNT_INTR) != 0,
 	       (data.flags & NFS_MOUNT_POSIX) != 0,
 	       (data.flags & NFS_MOUNT_NOCTO) != 0,
 	       (data.flags & NFS_MOUNT_NOAC) != 0);
 #if NFS_MOUNT_VERSION >= 2
-	printf("tcp = %d ",
+	printf(_(", tcp = %d"),
 	       (data.flags & NFS_MOUNT_TCP) != 0);
 #endif
 #if NFS_MOUNT_VERSION >= 4
-	printf("noacl = %d ", (data.flags & NFS_MOUNT_NOACL) != 0);
+	printf(_(", noacl = %d"), (data.flags & NFS_MOUNT_NOACL) != 0);
 #endif
 #if NFS_MOUNT_VERSION >= 5
-	printf("sec = %u ", data.pseudoflavor);
-	printf("readdirplus = %d ", (data.flags & NFS_MOUNT_NORDIRPLUS) != 0);
+	printf(_(", sec = %u"), data.pseudoflavor);
+	printf(_(", readdirplus = %d"), (data.flags & NFS_MOUNT_NORDIRPLUS) != 0);
 #endif
-	printf("\n");
+	printf(_("\n"));
 #endif
 
 	data.version = nfs_mount_data_version;
@@ -760,7 +759,7 @@ nfsmount(const char *spec, const char *node, int flags,
 			if (flavor[i] == data.pseudoflavor)
 				yum = 1;
 #ifdef NFS_MOUNT_DEBUG
-			printf("auth flavor %d: %d\n",
+			printf(_("auth flavor %d: %d\n"),
 				i, flavor[i]);
 #endif
 		}
@@ -803,7 +802,7 @@ noauth_flavors:
 	}
 
 #ifdef NFS_MOUNT_DEBUG
-	printf(_("using port %d for nfs deamon\n"), nfs_pmap->pm_port);
+	printf(_("using port %lu for nfs deamon\n"), nfs_pmap->pm_port);
 #endif
 	nfs_saddr->sin_port = htons(nfs_pmap->pm_port);
 	/*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
