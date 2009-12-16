From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] nfs: fix ISO C90 warning
Date: Wed, 16 Dec 2009 14:23:34 -0800
Message-ID: <20091216142334.6a0ba115.randy.dunlap@oracle.com>
References: <20091215165309.58e98eea.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:35213 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757222AbZLPWXq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 17:23:46 -0500
In-Reply-To: <20091215165309.58e98eea.sfr@canb.auug.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix gcc ISO C90 warning:

fs/nfs/callback.c:356: warning: ISO C90 forbids mixed declarations and code

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 fs/nfs/callback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20091215.orig/fs/nfs/callback.c
+++ linux-next-20091215/fs/nfs/callback.c
@@ -352,8 +352,8 @@ static int check_gss_callback_principal(
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct nfs_client *clp;
-	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 	int ret = SVC_OK;
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	/* Don't talk to strangers */
 	clp = nfs_find_client(svc_addr(rqstp), 4);
