Return-Path: <SRS0=UHwe=23=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08312C33C8C
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 13:17:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D50042071A
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 13:17:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726173AbgAFNRl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jan 2020 08:17:41 -0500
Received: from youngberry.canonical.com ([91.189.89.112]:44831 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726496AbgAFNRl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2020 08:17:41 -0500
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
        by youngberry.canonical.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.86_2)
        (envelope-from <colin.king@canonical.com>)
        id 1ioSGE-0006Gv-IX; Mon, 06 Jan 2020 13:17:34 +0000
From:   Colin King <colin.king@canonical.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Scott Mayhew <smayhew@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org
Cc:     kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH][next] NFS: Add missing null check for failed allocation
Date:   Mon,  6 Jan 2020 13:17:34 +0000
Message-Id: <20200106131734.51759-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.24.0
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Currently the allocation of buf is not being null checked and
a null pointer dereference can occur when the memory allocation fails.
Fix this by adding a check and returning -ENOMEM.

Addresses-Coverity: ("Dereference null return")
Fixes: 6d972518b821 ("NFS: Add fs_context support.")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/nfs/nfs4namespace.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 10e9e1887841..de6875a9b391 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -137,6 +137,9 @@ static int nfs4_validate_fspath(struct dentry *dentry,
 	int n;
 
 	buf = kmalloc(4096, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
 	path = nfs4_path(dentry, buf, 4096);
 	if (IS_ERR(path)) {
 		kfree(buf);
-- 
2.24.0

