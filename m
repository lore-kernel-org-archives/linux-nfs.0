Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga01-in.huawei.com ([119.145.14.64]:17491 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab3KHHXn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 02:23:43 -0500
Message-ID: <527C9170.9030005@huawei.com>
Date: Fri, 8 Nov 2013 15:23:28 +0800
From: Weng Meiling <wengmeiling.weng@huawei.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>, <bfields@fieldses.org>,
        Li Zefan <lizefan@huawei.com>
Subject: [PATCH] nfsd:add '\n' when read file supported_krb5_enctypes
References: <52786412.5030403@huawei.com>
In-Reply-To: <52786412.5030403@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


From: Weng Meiling <wengmeiling.weng@huawei.com>

Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfsctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f55517..31db42c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -188,7 +188,7 @@ static const struct file_operations export_features_operations = {
 #if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
 static int supported_enctypes_show(struct seq_file *m, void *v)
 {
-	seq_printf(m, KRB5_SUPPORTED_ENCTYPES);
+	seq_printf(m, "%s\n", KRB5_SUPPORTED_ENCTYPES);
 	return 0;
 }

-- 
1.8.3.1




