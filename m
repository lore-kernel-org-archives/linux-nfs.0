From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 16/26] gss_krb5: add DES3 to the list of
	supported enctypes
Date: Wed, 30 Apr 2008 12:47:09 -0400
Message-ID: <20080430164709.16010.75006.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:30623 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757363AbYD3QrK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:47:10 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This TEMPORARY patch notifies gssd that DES3 encryption is supported
by the kernel's gss_krb5 code.

This patch will go away when the final solution of adding the
enctype information to the upcall to gssd is implemented.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/rpc_pipe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5f159a0..c2d7817 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -392,7 +392,7 @@ static const struct file_operations rpc_info_operations = {
 static int
 rpc_show_krb5_info(struct seq_file *m, void *v)
 {
-	seq_printf(m, "enctypes: 3,1,2\n");
+	seq_printf(m, "enctypes: 16,3,1,2\n");
 	return 0;
 }
 

