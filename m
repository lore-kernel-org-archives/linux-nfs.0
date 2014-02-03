Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:41102 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaBCVCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 16:02:34 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] NFS: Add debugging message in nfs4_callback_null()
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 03 Feb 2014 16:02:32 -0500
Message-ID: <20140203210231.3533.33322.stgit@manet.1015granger.net>
In-Reply-To: <20140203205903.3533.39213.stgit@manet.1015granger.net>
References: <20140203205903.3533.39213.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's useful to see whether a server's callback probe reached our
callback server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback_xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f4ccfe6..c7e0c37 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -57,6 +57,7 @@ static struct callback_op callback_ops[];
 
 static __be32 nfs4_callback_null(struct svc_rqst *rqstp, void *argp, void *resp)
 {
+	dprintk("NFS: received CB_NULL from server %pIS\n", svc_addr(rqstp));
 	return htonl(NFS4_OK);
 }
 

