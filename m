From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 18/24] gss_krb5: add AES to the list of
	supported enctypes
Date: Tue, 06 May 2008 17:05:04 -0400
Message-ID: <20080506210504.3770.37286.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:9296 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763189AbYEFVFE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:05:04 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This TEMPORARY patch notifies gssd that AES encryption is supported
by the kernel's gss_krb5 code.

This patch will go away when the final solution of adding the
enctype information to the upcall to gssd is implemented.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/rpc_pipe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index c2d7817..d21afb4 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -392,7 +392,7 @@ static const struct file_operations rpc_info_operations = {
 static int
 rpc_show_krb5_info(struct seq_file *m, void *v)
 {
-	seq_printf(m, "enctypes: 16,3,1,2\n");
+	seq_printf(m, "enctypes: 18,17,16,3,1,2\n");
 	return 0;
 }
 

