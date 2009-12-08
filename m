From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] mount.nfs: Teach umount.nfs to recognize netids in
	/etc/mtab
Date: Tue, 08 Dec 2009 13:00:34 -0500
Message-ID: <20091208180033.2544.68238.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:41915 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965734AbZLHSAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:52 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

umount.nfs has to detect the correct address family to use when
looking up the server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index c5505b1..9d798a2 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -169,10 +169,15 @@ out:
 static int nfs_umount_do_umnt(struct mount_options *options,
 			      char **hostname, char **dirname)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *sap = (struct sockaddr *)&address;
+	union {
+		struct sockaddr		sa;
+		struct sockaddr_in	s4;
+		struct sockaddr_in6	s6;
+	} address;
+	struct sockaddr *sap = &address.sa;
 	socklen_t salen = sizeof(address);
 	struct pmap nfs_pmap, mnt_pmap;
+	sa_family_t family;
 
 	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap)) {
 		nfs_error(_("%s: bad mount options"), progname);
@@ -189,8 +194,10 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 		return EX_FAIL;
 	}
 
-	if (nfs_name_to_address(*hostname, sap, &salen) == 0)
-		/* nfs_name_to_address reports any errors */
+	if (!nfs_mount_proto_family(options, &family))
+		return 0;
+	if (!nfs_lookup(*hostname, family, sap, &salen))
+		/* nfs_lookup reports any errors */
 		return EX_FAIL;
 
 	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) == 0)

