Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:48018 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab2ALHGK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 02:06:10 -0500
Date: Thu, 12 Jan 2012 10:06:05 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] NFS: add an endian notation
Message-ID: <20120112070605.GA2975@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function returns a big endian value.  The implementation in
fs/nfs/callback_proc.c is declared with "__be32" but the .h file uses
"unsigned" instead.  It makes sparse complain:

fs/nfs/callback_proc.c:232:8: error:
	symbol 'nfs4_callback_layoutrecall' redeclared with different
	type (originally declared at fs/nfs/callback.h:165) - different
	base types

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 07df5f1..c89d3b9 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -162,7 +162,7 @@ struct cb_layoutrecallargs {
 	};
 };
 
-extern unsigned nfs4_callback_layoutrecall(
+extern __be32 nfs4_callback_layoutrecall(
 	struct cb_layoutrecallargs *args,
 	void *dummy, struct cb_process_state *cps);
 
