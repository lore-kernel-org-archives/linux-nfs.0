Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:61695 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758058Ab1EaSU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 14:20:59 -0400
Received: by gyd10 with SMTP id 10so1876850gyd.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 May 2011 11:20:59 -0700 (PDT)
Message-ID: <4DE5316D.1030906@gmail.com>
Date: Tue, 31 May 2011 14:20:29 -0400
From: Michael Groshans <mikegroshans@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd-lexp: Export correct ipv6 address for local exports
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Michael Groshans <groshans@umich.edu>

A sockaddr is not big enough to hold most ipv6 addresses. Changed to use
sockaddr_storage to hold the ipv6 address used for local exports.

Signed-off by: Michael Groshans <groshans@umich.edu>
---
 fs/nfsd/pnfsd.h                 |    2 +-
 fs/nfsd/pnfsd_lexp.c            |    6 +++---
 include/linux/sunrpc/svc_xprt.h |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index c11d93d..56adc53 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -135,7 +135,7 @@ void pnfs_set_device_notify(clientid_t *, unsigned int types);
 void pnfs_clear_device_notify(struct nfs4_client *);
 
 #if defined(CONFIG_PNFSD_LOCAL_EXPORT)
-extern struct sockaddr pnfsd_lexp_addr;
+extern struct sockaddr_storage pnfsd_lexp_addr;
 extern size_t pnfs_lexp_addr_len;
 
 extern void pnfsd_lexp_init(struct inode *);
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index e9382da..86614b1 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -27,7 +27,7 @@
 
 #define NFSDDBG_FACILITY NFSDDBG_PNFS
 
-struct sockaddr pnfsd_lexp_addr;
+struct sockaddr_storage pnfsd_lexp_addr;
 size_t pnfs_lexp_addr_len;
 
 static wait_queue_head_t lo_recall_wq;
@@ -87,7 +87,7 @@ pnfsd_lexp_get_device_info(struct super_block *sb,
 		goto out;
 	}
 
-	/* count the number of comma-delimited DS IPs */
+	/* format local address */
 	fdev.fl_device_length = 1;
 	fdev.fl_device_list = fl_devices;
 
@@ -100,7 +100,7 @@ pnfsd_lexp_get_device_info(struct super_block *sb,
 	if (err < 0)
 		goto out;
 	daddr.r_addr.len = err;
-	switch (pnfsd_lexp_addr.sa_family) {
+	switch (pnfsd_lexp_addr.ss_family) {
 	case AF_INET:
 		daddr.r_netid.data = "tcp";
 		daddr.r_netid.len = 3;
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 52cd57501..eff2127 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -208,13 +208,13 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
 /*
  * Print a network address in a universal format (see rfc1833 and nfsv4.1)
  */
-static inline int __svc_print_netaddr(struct sockaddr *addr,
+static inline int __svc_print_netaddr(struct sockaddr_storage *addr,
 				      struct xdr_netobj *na)
 {
 	u16 port;
 	ssize_t len;
 
-	switch (addr->sa_family) {
+	switch (addr->ss_family) {
 	case AF_INET: {
 		struct sockaddr_in *sin = (struct sockaddr_in *)addr;
 		port = ntohs(sin->sin_port);
@@ -235,7 +235,7 @@ static inline int __svc_print_netaddr(struct sockaddr *addr,
 	}
 	default:
 		snprintf(na->data, na->len, "unknown address type: %d",
-			 addr->sa_family);
+			 addr->ss_family);
 		len = -EINVAL;
 		break;
 	}
-- 
1.7.3.4
