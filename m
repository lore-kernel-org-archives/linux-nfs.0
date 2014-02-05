Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout2.samsung.com ([203.254.224.25]:30964 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbaBEGib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Feb 2014 01:38:31 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N0I00EBYFS557C0@mailout2.samsung.com> for
 linux-nfs@vger.kernel.org; Wed, 05 Feb 2014 15:38:29 +0900 (KST)
From: Jingoo Han <jg1.han@samsung.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "'Jingoo Han'" <jg1.han@samsung.com>
References: <000501cf223b$4b858490$e2908db0$%han@samsung.com>
In-reply-to: <000501cf223b$4b858490$e2908db0$%han@samsung.com>
Subject: [PATCH] sunrpc: replace strict_strtoul() with kstrtoul()
Date: Wed, 05 Feb 2014 15:38:29 +0900
Message-id: <001201cf223c$e156d4a0$a4047de0$%han@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 net/sunrpc/addr.c     |    8 ++++----
 net/sunrpc/auth.c     |    2 +-
 net/sunrpc/xprtsock.c |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index a622ad6..c0d3243 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -184,7 +184,7 @@ static int rpc_parse_scope_id(struct net *net, const char *buf,
 			scope_id = dev->ifindex;
 			dev_put(dev);
 		} else {
-			if (strict_strtoul(p, 10, &scope_id) == 0) {
+			if (kstrtoul(p, 10, &scope_id) == 0) {
 				kfree(p);
 				return 0;
 			}
@@ -304,7 +304,7 @@ char *rpc_sockaddr2uaddr(const struct sockaddr *sap, gfp_t gfp_flags)
  * @sap: buffer into which to plant socket address
  * @salen: size of buffer
  *
- * @uaddr does not have to be '\0'-terminated, but strict_strtoul() and
+ * @uaddr does not have to be '\0'-terminated, but kstrtoul() and
  * rpc_pton() require proper string termination to be successful.
  *
  * Returns the size of the socket address if successful; otherwise
@@ -327,7 +327,7 @@ size_t rpc_uaddr2sockaddr(struct net *net, const char *uaddr,
 	c = strrchr(buf, '.');
 	if (unlikely(c == NULL))
 		return 0;
-	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
+	if (unlikely(kstrtoul(c + 1, 10, &portlo) != 0))
 		return 0;
 	if (unlikely(portlo > 255))
 		return 0;
@@ -336,7 +336,7 @@ size_t rpc_uaddr2sockaddr(struct net *net, const char *uaddr,
 	c = strrchr(buf, '.');
 	if (unlikely(c == NULL))
 		return 0;
-	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
+	if (unlikely(kstrtoul(c + 1, 10, &porthi) != 0))
 		return 0;
 	if (unlikely(porthi > 255))
 		return 0;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead..0a64ffe 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -48,7 +48,7 @@ static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
 
 	if (!val)
 		goto out_inval;
-	ret = strict_strtoul(val, 0, &num);
+	ret = kstrtoul(val, 0, &num);
 	if (ret == -EINVAL)
 		goto out_inval;
 	nbits = fls(num);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 817a1e5..c66b0d4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3070,7 +3070,7 @@ static int param_set_uint_minmax(const char *val,
 
 	if (!val)
 		return -EINVAL;
-	ret = strict_strtoul(val, 0, &num);
+	ret = kstrtoul(val, 0, &num);
 	if (ret == -EINVAL || num < min || num > max)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
-- 
1.7.10.4


