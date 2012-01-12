Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:31535 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629Ab2ALHQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 02:16:24 -0500
Date: Thu, 12 Jan 2012 10:16:14 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfs: check for integer overflow in decode_devicenotify_args()
Message-ID: <20120112071614.GC2975@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 32 bit, if n is too large then "n * sizeof(*args->devs)" could
overflow and args->devs would be smaller than expected.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is a static checker fix.  I haven't tested this.  Sorry for that.

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 726e59a..d50b274 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -305,6 +305,10 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 	n = ntohl(*p++);
 	if (n <= 0)
 		goto out;
+	if (n > ULONG_MAX / sizeof(*args->devs)) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
 
 	args->devs = kmalloc(n * sizeof(*args->devs), GFP_KERNEL);
 	if (!args->devs) {
