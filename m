Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43313 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcDDSJ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2016 14:09:26 -0400
Message-ID: <5702ADD0.1040501@oracle.com>
Date: Mon, 04 Apr 2016 11:09:20 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, leon@leon.nu,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: [PATCH v3] svcrdma: add IPv6 support
References: <56E9A8DD.8030308@oracle.com> <20160317084210.GE25216@leon.nu> <9D93B217-3044-4404-8EB4-6CD0DD759642@oracle.com>
In-Reply-To: <9D93B217-3044-4404-8EB4-6CD0DD759642@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add rdma6 option to support NFS/RDMA IPv6 addressing.
Allow both IPv4 and IPv6 to bind same port at the same time,
restricts use of the IPv6 socket to IPv6 communication.

Changes from v1:
 - Check rdma_set_afonly return value (suggested by Leon Romanovsky)

Changes from v2:
 - Acked-by: Leon Romanovsky <leonro@mellanox.com>

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_transport.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 9066896..d2680b8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -789,7 +789,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	int ret;
 
 	dprintk("svcrdma: Creating RDMA socket\n");
-	if (sa->sa_family != AF_INET) {
+	if ((sa->sa_family != AF_INET) && (sa->sa_family != AF_INET6)) {
 		dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
@@ -805,6 +805,16 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 		goto err0;
 	}
 
+	/* Allow both IPv4 and IPv6 sockets to bind a single port
+	 * at the same time.
+	 */
+#if IS_ENABLED(CONFIG_IPV6)
+	ret = rdma_set_afonly(listen_id, 1);
+	if (ret) {
+		dprintk("svcrdma: rdma_set_afonly failed = %d\n", ret);
+		goto err1;
+	}
+#endif
 	ret = rdma_bind_addr(listen_id, sa);
 	if (ret) {
 		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
