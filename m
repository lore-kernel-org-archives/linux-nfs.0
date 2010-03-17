From: steved@redhat.com
Subject: [PATCH 16/23] gss_krb5: Update pipefs file
Date: Wed, 17 Mar 2010 13:03:01 -0400
Message-ID: <1268845388-9516-17-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43418 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754483Ab0CQR0F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:26:05 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweI-0003fC-Jz
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:14 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Update pipefs file indicating which Kerberos enctypes
the kernel supports

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/rpc_pipe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 266a9ae..780a2db 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -400,7 +400,7 @@ static const struct file_operations rpc_info_operations = {
 static int
 rpc_show_krb5_info(struct seq_file *m, void *v)
 {
-	seq_printf(m, "enctypes: 16,3,1,2\n");
+	seq_printf(m, "enctypes: 18,17,16,3,1,2\n");
 	return 0;
 }
 
-- 
1.6.6.1

