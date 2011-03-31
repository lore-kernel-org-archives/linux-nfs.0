Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34831 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034Ab1CaVgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2011 17:36:31 -0400
Received: by bwz15 with SMTP id 15so2090637bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2011 14:36:29 -0700 (PDT)
Date: Fri, 1 Apr 2011 00:36:25 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: kstrtox: convert net/sunrpc/
Message-ID: <20110331213625.GA3637@p183.telecom.by>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* fix a bug in rpc_parse_scope_id() where successfull parsing of
  scope ID was an error.
  
  I'm not sure whether ID=0 should be banned, though.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/sunrpc/addr.c     |   20 ++++++++------------
 net/sunrpc/auth.c     |   15 ++++++---------
 net/sunrpc/xprtsock.c |    8 +++++---
 3 files changed, 19 insertions(+), 24 deletions(-)

--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -173,15 +173,15 @@ static int rpc_parse_scope_id(const char *buf, const size_t buflen,
 	len = (buf + buflen) - delim - 1;
 	p = kstrndup(delim + 1, len, GFP_KERNEL);
 	if (p) {
-		unsigned long scope_id = 0;
 		struct net_device *dev;
+		u32 scope_id;
 
 		dev = dev_get_by_name(&init_net, p);
 		if (dev != NULL) {
 			scope_id = dev->ifindex;
 			dev_put(dev);
 		} else {
-			if (strict_strtoul(p, 10, &scope_id) == 0) {
+			if (kstrtou32(p, 10, &scope_id) < 0) {
 				kfree(p);
 				return 0;
 			}
@@ -299,7 +299,7 @@ EXPORT_SYMBOL_GPL(rpc_sockaddr2uaddr);
  * @sap: buffer into which to plant socket address
  * @salen: size of buffer
  *
- * @uaddr does not have to be '\0'-terminated, but strict_strtoul() and
+ * @uaddr does not have to be '\0'-terminated, but kstrto*() and
  * rpc_pton() require proper string termination to be successful.
  *
  * Returns the size of the socket address if successful; otherwise
@@ -309,8 +309,8 @@ size_t rpc_uaddr2sockaddr(const char *uaddr, const size_t uaddr_len,
 			  struct sockaddr *sap, const size_t salen)
 {
 	char *c, buf[RPCBIND_MAXUADDRLEN + sizeof('\0')];
-	unsigned long portlo, porthi;
-	unsigned short port;
+	u8 portlo, porthi;
+	u16 port;
 
 	if (uaddr_len > RPCBIND_MAXUADDRLEN)
 		return 0;
@@ -321,21 +321,17 @@ size_t rpc_uaddr2sockaddr(const char *uaddr, const size_t uaddr_len,
 	c = strrchr(buf, '.');
 	if (unlikely(c == NULL))
 		return 0;
-	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
-		return 0;
-	if (unlikely(portlo > 255))
+	if (unlikely(kstrtou8(c + 1, 10, &portlo) != 0))
 		return 0;
 
 	*c = '\0';
 	c = strrchr(buf, '.');
 	if (unlikely(c == NULL))
 		return 0;
-	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
-		return 0;
-	if (unlikely(porthi > 255))
+	if (unlikely(kstrtou8(c + 1, 10, &porthi) != 0))
 		return 0;
 
-	port = (unsigned short)((porthi << 8) | portlo);
+	port = (porthi << 8) | portlo;
 
 	*c = '\0';
 	if (rpc_pton(buf, strlen(buf), sap, salen) == 0)
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -41,24 +41,21 @@ static unsigned long number_cred_unused;
 #define MAX_HASHTABLE_BITS (14)
 static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
 {
-	unsigned long num;
-	unsigned int nbits;
+	unsigned int num, nbits;
 	int ret;
 
 	if (!val)
-		goto out_inval;
-	ret = strict_strtoul(val, 0, &num);
-	if (ret == -EINVAL)
-		goto out_inval;
+		return -EINVAL;
+	ret = kstrtouint(val, 0, &num);
+	if (ret < 0)
+		return ret;
 	nbits = fls(num);
 	if (num > (1U << nbits))
 		nbits++;
 	if (nbits > MAX_HASHTABLE_BITS || nbits < 2)
-		goto out_inval;
+		return -EINVAL;
 	*(unsigned int *)kp->arg = nbits;
 	return 0;
-out_inval:
-	return -EINVAL;
 }
 
 static int param_get_hashtbl_sz(char *buffer, const struct kernel_param *kp)
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2502,13 +2502,15 @@ static int param_set_uint_minmax(const char *val,
 		const struct kernel_param *kp,
 		unsigned int min, unsigned int max)
 {
-	unsigned long num;
+	unsigned int num;
 	int ret;
 
 	if (!val)
 		return -EINVAL;
-	ret = strict_strtoul(val, 0, &num);
-	if (ret == -EINVAL || num < min || num > max)
+	ret = kstrtouint(val, 0, &num);
+	if (ret < 0)
+		return ret;
+	if (num < min || num > max)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
 	return 0;
