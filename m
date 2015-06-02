Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:33103 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbbFBK70 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jun 2015 06:59:26 -0400
Received: by qcmi9 with SMTP id i9so57975560qcm.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jun 2015 03:59:25 -0700 (PDT)
Message-ID: <556D8C87.2000507@gmail.com>
Date: Tue, 02 Jun 2015 18:59:19 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 1/2] nfsd: Reset cb_status in nfsd4_cb_prepare() at retrying
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd enters a infinite loop and print message per 10 seconds,

May 31 18:33:52 test-server kernel: Error sending entire callback!
May 31 18:34:01 test-server kernel: Error sending entire callback!

It is caused by a cb_layoutreturn got error -10008 (NFS4ERR_DELAY),
and then, the client crash, nfsd enter the infinite loop.

bc_sendto --> call_timeout --> nfsd4_cb_done --> nfsd4_cb_layout_done
 with error -10008 --> rpc_delay(task, HZ/100) --> bc_sendto ...

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5694cfb..8b1ac8d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -875,6 +875,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	u32 minorversion = clp->cl_minorversion;
 
 	cb->cb_minorversion = minorversion;
+	cb->cb_status = 0;
 	if (minorversion) {
 		if (!nfsd41_cb_get_slot(clp, task))
 			return;
-- 
2.4.2

