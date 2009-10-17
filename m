From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/3] nfsmount.conf: New variables that explicitly set default
 (Release 3)
Date: Sat, 17 Oct 2009 09:39:35 -0400
Message-ID: <4AD9C917.1090408@RedHat.com>
References: <4AD9C871.3000400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbZJQNjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Oct 2009 09:39:46 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDdobO029988
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:39:51 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-234.rdu.redhat.com [10.11.10.234])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDdoTp018023
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:39:50 -0400
In-Reply-To: <4AD9C871.3000400-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit dbab932b4563744084d7ea22ad593173295e494e
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Oct 17 09:26:18 2009 -0400

    Use the default protocol and version values, when they
    are set in the configuration file, to start the negation
    with the server
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 1a05351..e651167 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -50,6 +50,7 @@
 #include "nfsrpc.h"
 #include "parse_opt.h"
 #include "network.h"
+#include "conffile.h"
 
 #define PMAP_TIMEOUT	(10)
 #define CONNECT_TIMEOUT	(20)
@@ -609,10 +610,19 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
-	if (nfs_mount_data_version >= 4)
+	if (nfs_mount_data_version >= 4) {
+		const unsigned int *probe_proto = probe_tcp_first;
+
+		/*
+		 * If the default proto has been set and 
+		 * its not TCP, start with UDP
+		 */
+		if (config_default_proto && config_default_proto != IPPROTO_TCP)
+			probe_proto =  probe_udp_first;
+
 		return nfs_probe_port(sap, salen, pmap,
-					probe_nfs3_first, probe_tcp_first);
-	else
+					probe_nfs3_first, probe_proto);
+	} else
 		return nfs_probe_port(sap, salen, pmap,
 					probe_nfs2_only, probe_udp_only);
 }
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 069bdc1..ceefdb0 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -45,6 +45,7 @@
 #include "parse_opt.h"
 #include "version.h"
 #include "parse_dev.h"
+#include "conffile.h"
 
 #ifndef NFS_PROGRAM
 #define NFS_PROGRAM	(100003)
@@ -283,6 +284,14 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 		if (option && strcmp(option, "rdma") == 0)
 			mi->version = 3;
 	}
+	/*
+	 * Use the default value set in the config file when
+	 * the version has not been explicitly set.
+	 */
+	if (mi->version == 0 && config_default_vers) {
+		if (config_default_vers < 4)
+			mi->version = config_default_vers;
+	}
 
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;

