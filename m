From: andros@netapp.com
Subject: [PATCH 1/3] SQUASHME pnfs_submit: use MDS session for dual MDS/DS
Date: Wed, 12 May 2010 13:39:38 -0400
Message-ID: <1273685980-3340-2-git-send-email-andros@netapp.com>
References: <1273685980-3340-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756415Ab0ELRkK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 13:40:10 -0400
In-Reply-To: <1273685980-3340-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We currently only have one session per clientid. If the deviceid maps the MDS
server as a data server, use the MDS session for the data server traffic only
if EXCHGID4_FLAG_USE_PNFS_DS is set as an MDS clientid pNFS role.

Squash into "pnfs: filelayout: device ops"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |    3 ++-
 fs/nfs/internal.h          |    2 ++
 fs/nfs/nfs4filelayoutdev.c |   20 +++++++++++++++++++-
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0337330..1979831 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -348,7 +348,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
  * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, including the port number.
  */
-static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 			    const struct sockaddr *sa2)
 {
 	if (sa1->sa_family != sa2->sa_family)
@@ -362,6 +362,7 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	}
 	return 0;
 }
+EXPORT_SYMBOL(nfs_sockaddr_cmp);
 
 /*
  * Find a client by IP address and protocol version
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 83f2953..92f3231 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -139,6 +139,8 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
+extern int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+		const struct sockaddr *sa2);
 extern int nfs4_set_client(struct nfs_server *server,
 		const char *hostname,
 		const struct sockaddr *addr,
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 462f6de..891c31d 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -126,7 +126,8 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	};
 	struct sockaddr_in	sin;
 	struct rpc_clnt 	*mds_clnt = mds_srv->client;
-	struct nfs_client 	*clp;
+	struct nfs_client	*clp = mds_srv->nfs_client;
+	struct sockaddr		*mds_addr;
 	char			ip_addr[16];
 	int			addrlen;
 	int err = 0;
@@ -138,6 +139,23 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	sin.sin_addr.s_addr = ds->ds_ip_addr;
 	sin.sin_port = ds->ds_port;
 
+	/*
+	 * If this DS is also the MDS, use the MDS session only if the
+	 * MDS exchangeid flags show the EXCHGID4_FLAG_USE_PNFS_DS pNFS role.
+	 */
+	mds_addr = (struct sockaddr *)&clp->cl_addr;
+	if (nfs_sockaddr_cmp((struct sockaddr *)&sin, mds_addr)) {
+		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
+			printk(KERN_INFO "ip:port %s is not a pNFS Data "
+				"Server\n", ds->r_addr);
+			err = -ENODEV;
+		} else {
+			atomic_inc(&clp->cl_count);
+			ds->ds_clp = clp;
+			dprintk("%s Using MDS Session for DS\n", __func__);
+		}
+		goto out;
+	}
 	/* Set timeout to the mds rpc clnt value.
 	 * XXX - find the correct authflavor....
 	 *
-- 
1.6.6

