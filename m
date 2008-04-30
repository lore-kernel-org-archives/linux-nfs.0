From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 26/26] gss_krb5: add RC4 to the list of
	supported enctypes
Date: Wed, 30 Apr 2008 12:48:00 -0400
Message-ID: <20080430164800.16010.12887.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:46018 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757914AbYD3QsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:48:00 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This TEMPORARY patch notifies gssd that RC4 encryption is supported
by the kernel's gss_krb5 code.

This patch will go away when the final solution of adding the
enctype information to the upcall to gssd is implemented.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/rpc_pipe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index d21afb4..b1d8ed6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -392,7 +392,7 @@ static const struct file_operations rpc_info_operations = {
 static int
 rpc_show_krb5_info(struct seq_file *m, void *v)
 {
-	seq_printf(m, "enctypes: 18,17,16,3,1,2\n");
+	seq_printf(m, "enctypes: 18,17,16,23,3,1,2\n");
 	return 0;
 }
 

