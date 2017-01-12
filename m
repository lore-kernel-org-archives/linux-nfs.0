Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35516 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbdALPik (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 10:38:40 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so4025696pfa.2
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 07:38:12 -0800 (PST)
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-nfs@vger.kernel.org
Subject: [PATCH -next] pNFS/flexfiles: Make local symbol layoutreturn_ops static
Date: Thu, 12 Jan 2017 15:38:06 +0000
Message-Id: <20170112153806.27741-1-weiyj.lk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

fs/nfs/flexfilelayout/flexfilelayout.c:2114:34: warning:
 symbol 'layoutreturn_ops' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ca1012a..5f0747c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2111,7 +2111,7 @@ ff_layout_free_layoutreturn(struct nfs4_xdr_opaque_data *args)
 	kfree(ff_args);
 }
 
-const struct nfs4_xdr_opaque_ops layoutreturn_ops = {
+static const struct nfs4_xdr_opaque_ops layoutreturn_ops = {
 	.encode = ff_layout_encode_layoutreturn,
 	.free = ff_layout_free_layoutreturn,
 };

