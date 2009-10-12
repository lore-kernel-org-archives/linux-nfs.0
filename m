From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/3] nfsmount.conf: New variables that explicitly set default
 (Release 2)
Date: Mon, 12 Oct 2009 17:38:55 -0400
Message-ID: <4AD3A1EF.9020007@RedHat.com>
References: <4AD3A0BA.3080104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933272AbZJLVjf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 17:39:35 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLd9me005113
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:39:09 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-119.rdu.redhat.com [10.11.10.119])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLd7hO009758
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:39:08 -0400
In-Reply-To: <4AD3A0BA.3080104-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit c1cf5467f3e6355b8cb19ecda5688895b912bf49
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Oct 12 17:08:59 2009 -0400

    If a mount fails due to the server not supporting the
    version or network proto and either one of those options
    were set as defaults in the configuration file, retry
    the mount, after removing the options from list optlist
    allow the mount to negotiate to the supported version
    or network protocol.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 069bdc1..35b0797 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -92,6 +92,13 @@ struct nfsmount_info {
 				child;		/* forked bg child? */
 };
 
+#ifdef MOUNT_CONFIG
+#include "conffile.h"
+int inline config_defaults(struct nfsmount_info *mi);
+#else
+int inline config_defaults(struct nfsmount_info *mi) {return 0;}
+#endif
+
 /*
  * Obtain a retry timeout value based on the value of the "retry=" option.
  *
@@ -610,10 +617,22 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	case 2:
 	case 3:
 		result = nfs_try_mount_v3v2(mi);
+		if (result)
+			break;
+
+		if (config_defaults(mi))
+			result = nfs_try_mount_v3v2(mi);
 		break;
+
 	case 4:
 		result = nfs_try_mount_v4(mi);
+		if (result)
+			break;
+
+		if (config_defaults(mi))
+			result = nfs_try_mount_v3v2(mi);
 		break;
+
 	default:
 		errno = EIO;
 	}
@@ -819,3 +838,36 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	free(mi.hostname);
 	return retval;
 }
+
+#ifdef MOUNT_CONFIG
+/*
+ * If the mount fails due to a ENOSUPPORT type of error
+ * and a default options were set in the configuration file
+ * try the mount again without that default options set.
+ */
+int inline config_defaults(struct nfsmount_info *mi)
+{
+	if (!config_default_opts)
+		return 0;
+
+	switch(mi->version) {
+	case 4:
+		if (errno != EPROTONOSUPPORT)
+			return 0;
+		break;
+	case 3:
+		if (errno != ESPIPE)
+			return 0;
+		break;
+	default:
+		return 0;
+	}
+	if (config_default_opts && DEFAULT_VERS)
+		po_remove_all(mi->options, "vers");
+
+	if (config_default_opts && DEFAULT_PROTO)
+		po_remove_all(mi->options, "proto");
+
+	return 1;
+}
+#endif

