Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:35338 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932208AbcFCMqY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jun 2016 08:46:24 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 6C4C2280AD6
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jun 2016 14:46:21 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 5323913E83
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jun 2016 14:46:21 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Yves Kemp <yves.kemp@desy.de>, Trond Myklebust <trondmy@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4: clnt: respect noresvport when establishing connections to DSes
Date: Fri,  3 Jun 2016 14:46:17 +0200
Message-Id: <1464957977-9077-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1464957977-9077-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1464955723-4678-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1464957977-9077-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

result:

$ mount -o vers=4.1 dcache-lab007:/ /pnfs
$ cp /etc/profile /pnfs
tcp        0      0 131.169.185.68:1005     131.169.191.141:32049   ESTABLISHED
tcp        0      0 131.169.185.68:751      131.169.191.144:2049    ESTABLISHED
$

$ mount -o vers=4.1,noresvport dcache-lab007:/ /pnfs
$ cp /etc/profile /pnfs
tcp        0      0 131.169.185.68:34894    131.169.191.141:32049   ESTABLISHED
tcp        0      0 131.169.185.68:35722    131.169.191.144:2049    ESTABLISHED
$

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/internal.h   | 1 +
 fs/nfs/nfs4client.c | 5 ++++-
 fs/nfs/pnfs_nfs.c   | 2 ++
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5154fa6..e8b2192 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -185,6 +185,7 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 extern int nfs_wait_client_init_complete(const struct nfs_client *clp);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+					     int noresvport,
 					     const struct sockaddr *ds_addr,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 10410e8..6cfb5f9 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -842,7 +842,7 @@ error:
  * low timeout interval so that if a connection is lost, we retry through
  * the MDS.
  */
-struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp, int noresvport,
 		const struct sockaddr *ds_addr, int ds_addrlen,
 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
 		u32 minor_version, rpc_authflavor_t au_flavor)
@@ -863,6 +863,9 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		return ERR_PTR(-EINVAL);
 	cl_init.hostname = buf;
 
+	if (noresvport)
+		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+
 	/*
 	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
 	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 0dfc476..b4ac66d 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
 #include <linux/nfs_page.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/module.h>
@@ -683,6 +684,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
 		clp = nfs4_set_ds_client(mds_srv->nfs_client,
+					mds_srv->flags & NFS_MOUNT_NORESVPORT ? 1 : 0,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
 					timeo, retrans, minor_version,
-- 
2.5.5

