Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487Ab2D0VpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:14 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 05/13] NFSv4.1 data server timeo and retrans module parameters
Date: Fri, 27 Apr 2012 17:53:45 -0400
Message-Id: <1335563633-7191-6-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the recovery parameters for data servers.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |   12 ++++--------
 fs/nfs/internal.h          |    4 +++-
 fs/nfs/nfs4filelayout.h    |    7 +++++++
 fs/nfs/nfs4filelayoutdev.c |   18 ++++++++++++++++--
 4 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index da7b5e4..0f54732 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1465,8 +1465,8 @@ error:
  * the MDS.
  */
 struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
-		const struct sockaddr *ds_addr,
-		int ds_addrlen, int ds_proto)
+		const struct sockaddr *ds_addr, int ds_addrlen,
+		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans)
 {
 	struct nfs_client_initdata cl_init = {
 		.addr = ds_addr,
@@ -1476,12 +1476,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		.minorversion = mds_clp->cl_minorversion,
 		.net = mds_clp->net,
 	};
-	struct rpc_timeout ds_timeout = {
-		.to_initval = 15 * HZ,
-		.to_maxval = 15 * HZ,
-		.to_retries = 1,
-		.to_exponential = 1,
-	};
+	struct rpc_timeout ds_timeout;
 	struct nfs_client *clp;
 
 	/*
@@ -1489,6 +1484,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
 	 * (section 13.1 RFC 5661).
 	 */
+	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
 	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
 			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5026bcc..f38e099 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -170,7 +170,9 @@ extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     const struct sockaddr *ds_addr,
-					     int ds_addrlen, int ds_proto);
+					     int ds_addrlen, int ds_proto,
+					     unsigned int ds_timeo,
+					     unsigned int ds_retrans);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 2f6330c..6fb1901 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -33,6 +33,13 @@
 #include "pnfs.h"
 
 /*
+ * Default data server connection timeout and retrans vaules.
+ * Set by module paramters dataserver_timeo and dataserver_retrans.
+ */
+#define NFS4_DEF_DS_TIMEO   60
+#define NFS4_DEF_DS_RETRANS 5
+
+/*
  * Field testing shows we need to support up to 4096 stripe indices.
  * We store each index as a u8 (u32 on the wire) to keep the memory footprint
  * reasonable. This in turn means we support a maximum of 256
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 2b8ae96..d5a92cf 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -30,12 +30,16 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/vmalloc.h>
+#include <linux/module.h>
 
 #include "internal.h"
 #include "nfs4filelayout.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
+static unsigned int dataserver_timeo = NFS4_DEF_DS_TIMEO;
+static unsigned int dataserver_retrans = NFS4_DEF_DS_RETRANS;
+
 /*
  * Data server cache
  *
@@ -165,8 +169,9 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
 		clp = nfs4_set_ds_client(mds_srv->nfs_client,
-				 (struct sockaddr *)&da->da_addr,
-				 da->da_addrlen, IPPROTO_TCP);
+					(struct sockaddr *)&da->da_addr,
+					da->da_addrlen, IPPROTO_TCP,
+					dataserver_timeo, dataserver_retrans);
 		if (!IS_ERR(clp))
 			break;
 	}
@@ -821,3 +826,12 @@ mark_dev_invalid:
 	filelayout_mark_devid_invalid(devid);
 	return NULL;
 }
+
+module_param(dataserver_retrans, uint, 0644);
+MODULE_PARM_DESC(dataserver_retrans, "The  number of times the NFSv4.1 client "
+			"retries a request before it attempts further "
+			" recovery  action.");
+module_param(dataserver_timeo, uint, 0644);
+MODULE_PARM_DESC(dataserver_timeo, "The time (in tenths of a second) the "
+			"NFSv4.1  client  waits for a response from a "
+			" data server before it retries an NFS request.");
-- 
1.7.6.4

