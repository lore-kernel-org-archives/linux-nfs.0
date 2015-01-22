Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53098 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbbAVXgm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:36:42 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so4570094pdb.11
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:36:42 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 04/51] nfs41: pull decode_ds_addr from file layout to generic pnfs
Date: Thu, 22 Jan 2015 15:35:36 -0800
Message-Id: <1421969783-92997-5-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

It can be reused by flexfile layout.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayoutdev.c | 152 +-------------------------------------
 fs/nfs/pnfs.h                     |   3 +
 fs/nfs/pnfs_nfs.c                 | 149 +++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 150 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index fbfbb70..c7f6041 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -31,7 +31,6 @@
 #include <linux/nfs_fs.h>
 #include <linux/vmalloc.h>
 #include <linux/module.h>
-#include <linux/sunrpc/addr.h>
 
 #include "../internal.h"
 #include "../nfs4session.h"
@@ -104,153 +103,6 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 	kfree(dsaddr);
 }
 
-/*
- * Currently only supports ipv4, ipv6 and one multi-path address.
- */
-static struct nfs4_pnfs_ds_addr *
-decode_ds_addr(struct net *net, struct xdr_stream *streamp, gfp_t gfp_flags)
-{
-	struct nfs4_pnfs_ds_addr *da = NULL;
-	char *buf, *portstr;
-	__be16 port;
-	int nlen, rlen;
-	int tmp[2];
-	__be32 *p;
-	char *netid, *match_netid;
-	size_t len, match_netid_len;
-	char *startsep = "";
-	char *endsep = "";
-
-
-	/* r_netid */
-	p = xdr_inline_decode(streamp, 4);
-	if (unlikely(!p))
-		goto out_err;
-	nlen = be32_to_cpup(p++);
-
-	p = xdr_inline_decode(streamp, nlen);
-	if (unlikely(!p))
-		goto out_err;
-
-	netid = kmalloc(nlen+1, gfp_flags);
-	if (unlikely(!netid))
-		goto out_err;
-
-	netid[nlen] = '\0';
-	memcpy(netid, p, nlen);
-
-	/* r_addr: ip/ip6addr with port in dec octets - see RFC 5665 */
-	p = xdr_inline_decode(streamp, 4);
-	if (unlikely(!p))
-		goto out_free_netid;
-	rlen = be32_to_cpup(p);
-
-	p = xdr_inline_decode(streamp, rlen);
-	if (unlikely(!p))
-		goto out_free_netid;
-
-	/* port is ".ABC.DEF", 8 chars max */
-	if (rlen > INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 8) {
-		dprintk("%s: Invalid address, length %d\n", __func__,
-			rlen);
-		goto out_free_netid;
-	}
-	buf = kmalloc(rlen + 1, gfp_flags);
-	if (!buf) {
-		dprintk("%s: Not enough memory\n", __func__);
-		goto out_free_netid;
-	}
-	buf[rlen] = '\0';
-	memcpy(buf, p, rlen);
-
-	/* replace port '.' with '-' */
-	portstr = strrchr(buf, '.');
-	if (!portstr) {
-		dprintk("%s: Failed finding expected dot in port\n",
-			__func__);
-		goto out_free_buf;
-	}
-	*portstr = '-';
-
-	/* find '.' between address and port */
-	portstr = strrchr(buf, '.');
-	if (!portstr) {
-		dprintk("%s: Failed finding expected dot between address and "
-			"port\n", __func__);
-		goto out_free_buf;
-	}
-	*portstr = '\0';
-
-	da = kzalloc(sizeof(*da), gfp_flags);
-	if (unlikely(!da))
-		goto out_free_buf;
-
-	INIT_LIST_HEAD(&da->da_node);
-
-	if (!rpc_pton(net, buf, portstr-buf, (struct sockaddr *)&da->da_addr,
-		      sizeof(da->da_addr))) {
-		dprintk("%s: error parsing address %s\n", __func__, buf);
-		goto out_free_da;
-	}
-
-	portstr++;
-	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
-	port = htons((tmp[0] << 8) | (tmp[1]));
-
-	switch (da->da_addr.ss_family) {
-	case AF_INET:
-		((struct sockaddr_in *)&da->da_addr)->sin_port = port;
-		da->da_addrlen = sizeof(struct sockaddr_in);
-		match_netid = "tcp";
-		match_netid_len = 3;
-		break;
-
-	case AF_INET6:
-		((struct sockaddr_in6 *)&da->da_addr)->sin6_port = port;
-		da->da_addrlen = sizeof(struct sockaddr_in6);
-		match_netid = "tcp6";
-		match_netid_len = 4;
-		startsep = "[";
-		endsep = "]";
-		break;
-
-	default:
-		dprintk("%s: unsupported address family: %u\n",
-			__func__, da->da_addr.ss_family);
-		goto out_free_da;
-	}
-
-	if (nlen != match_netid_len || strncmp(netid, match_netid, nlen)) {
-		dprintk("%s: ERROR: r_netid \"%s\" != \"%s\"\n",
-			__func__, netid, match_netid);
-		goto out_free_da;
-	}
-
-	/* save human readable address */
-	len = strlen(startsep) + strlen(buf) + strlen(endsep) + 7;
-	da->da_remotestr = kzalloc(len, gfp_flags);
-
-	/* NULL is ok, only used for dprintk */
-	if (da->da_remotestr)
-		snprintf(da->da_remotestr, len, "%s%s%s:%u", startsep,
-			 buf, endsep, ntohs(port));
-
-	dprintk("%s: Parsed DS addr %s\n", __func__, da->da_remotestr);
-	kfree(buf);
-	kfree(netid);
-	return da;
-
-out_free_da:
-	kfree(da);
-out_free_buf:
-	dprintk("%s: Error parsing DS addr: %s\n", __func__, buf);
-	kfree(buf);
-out_free_netid:
-	kfree(netid);
-out_err:
-	return NULL;
-}
-
 /* Decode opaque device data and return the result */
 struct nfs4_file_layout_dsaddr *
 nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
@@ -353,8 +205,8 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 
 		mp_count = be32_to_cpup(p); /* multipath count */
 		for (j = 0; j < mp_count; j++) {
-			da = decode_ds_addr(server->nfs_client->cl_net,
-					    &stream, gfp_flags);
+			da = nfs4_decode_mp_ds_addr(server->nfs_client->cl_net,
+						    &stream, gfp_flags);
 			if (da)
 				list_add_tail(&da->da_node, &dsaddrs);
 		}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b0168f1..403d7bb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -312,6 +312,9 @@ void pnfs_generic_write_commit_done(struct rpc_task *task, void *data);
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
 				      gfp_t gfp_flags);
+struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
+						 struct xdr_stream *xdr,
+						 gfp_t gfp_flags);
 
 static inline struct nfs4_deviceid_node *
 nfs4_get_deviceid(struct nfs4_deviceid_node *d)
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 3bb2b74..81ec449 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -9,6 +9,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/sunrpc/addr.h>
 
 #include "internal.h"
 #include "pnfs.h"
@@ -532,3 +533,151 @@ out:
 	return ds;
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_add);
+
+/*
+ * Currently only supports ipv4, ipv6 and one multi-path address.
+ */
+struct nfs4_pnfs_ds_addr *
+nfs4_decode_mp_ds_addr(struct net *net, struct xdr_stream *xdr, gfp_t gfp_flags)
+{
+	struct nfs4_pnfs_ds_addr *da = NULL;
+	char *buf, *portstr;
+	__be16 port;
+	int nlen, rlen;
+	int tmp[2];
+	__be32 *p;
+	char *netid, *match_netid;
+	size_t len, match_netid_len;
+	char *startsep = "";
+	char *endsep = "";
+
+
+	/* r_netid */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_err;
+	nlen = be32_to_cpup(p++);
+
+	p = xdr_inline_decode(xdr, nlen);
+	if (unlikely(!p))
+		goto out_err;
+
+	netid = kmalloc(nlen+1, gfp_flags);
+	if (unlikely(!netid))
+		goto out_err;
+
+	netid[nlen] = '\0';
+	memcpy(netid, p, nlen);
+
+	/* r_addr: ip/ip6addr with port in dec octets - see RFC 5665 */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_free_netid;
+	rlen = be32_to_cpup(p);
+
+	p = xdr_inline_decode(xdr, rlen);
+	if (unlikely(!p))
+		goto out_free_netid;
+
+	/* port is ".ABC.DEF", 8 chars max */
+	if (rlen > INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 8) {
+		dprintk("%s: Invalid address, length %d\n", __func__,
+			rlen);
+		goto out_free_netid;
+	}
+	buf = kmalloc(rlen + 1, gfp_flags);
+	if (!buf) {
+		dprintk("%s: Not enough memory\n", __func__);
+		goto out_free_netid;
+	}
+	buf[rlen] = '\0';
+	memcpy(buf, p, rlen);
+
+	/* replace port '.' with '-' */
+	portstr = strrchr(buf, '.');
+	if (!portstr) {
+		dprintk("%s: Failed finding expected dot in port\n",
+			__func__);
+		goto out_free_buf;
+	}
+	*portstr = '-';
+
+	/* find '.' between address and port */
+	portstr = strrchr(buf, '.');
+	if (!portstr) {
+		dprintk("%s: Failed finding expected dot between address and "
+			"port\n", __func__);
+		goto out_free_buf;
+	}
+	*portstr = '\0';
+
+	da = kzalloc(sizeof(*da), gfp_flags);
+	if (unlikely(!da))
+		goto out_free_buf;
+
+	INIT_LIST_HEAD(&da->da_node);
+
+	if (!rpc_pton(net, buf, portstr-buf, (struct sockaddr *)&da->da_addr,
+		      sizeof(da->da_addr))) {
+		dprintk("%s: error parsing address %s\n", __func__, buf);
+		goto out_free_da;
+	}
+
+	portstr++;
+	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
+	port = htons((tmp[0] << 8) | (tmp[1]));
+
+	switch (da->da_addr.ss_family) {
+	case AF_INET:
+		((struct sockaddr_in *)&da->da_addr)->sin_port = port;
+		da->da_addrlen = sizeof(struct sockaddr_in);
+		match_netid = "tcp";
+		match_netid_len = 3;
+		break;
+
+	case AF_INET6:
+		((struct sockaddr_in6 *)&da->da_addr)->sin6_port = port;
+		da->da_addrlen = sizeof(struct sockaddr_in6);
+		match_netid = "tcp6";
+		match_netid_len = 4;
+		startsep = "[";
+		endsep = "]";
+		break;
+
+	default:
+		dprintk("%s: unsupported address family: %u\n",
+			__func__, da->da_addr.ss_family);
+		goto out_free_da;
+	}
+
+	if (nlen != match_netid_len || strncmp(netid, match_netid, nlen)) {
+		dprintk("%s: ERROR: r_netid \"%s\" != \"%s\"\n",
+			__func__, netid, match_netid);
+		goto out_free_da;
+	}
+
+	/* save human readable address */
+	len = strlen(startsep) + strlen(buf) + strlen(endsep) + 7;
+	da->da_remotestr = kzalloc(len, gfp_flags);
+
+	/* NULL is ok, only used for dprintk */
+	if (da->da_remotestr)
+		snprintf(da->da_remotestr, len, "%s%s%s:%u", startsep,
+			 buf, endsep, ntohs(port));
+
+	dprintk("%s: Parsed DS addr %s\n", __func__, da->da_remotestr);
+	kfree(buf);
+	kfree(netid);
+	return da;
+
+out_free_da:
+	kfree(da);
+out_free_buf:
+	dprintk("%s: Error parsing DS addr: %s\n", __func__, buf);
+	kfree(buf);
+out_free_netid:
+	kfree(netid);
+out_err:
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(nfs4_decode_mp_ds_addr);
-- 
1.9.3

