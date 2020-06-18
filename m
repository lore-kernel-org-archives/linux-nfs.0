Return-Path: <SRS0=2npy=77=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D701EC433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jun 2020 01:44:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B44812222F
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jun 2020 01:44:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1592444689;
	bh=8v/jcvfIvMO4FvTNn2ccGQXv+Rodw+T1uuSu+tjYeQk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=XZYl1rxsW0kPHCD52DLn4mKr3alUAeWxEbjIOAb3bUlk2U10rytzpSb7DeG089V7K
	 CAaiqacmTqUvu1kBQ1ia4qga7fttS4kSfnB2gLjiAWBzrc6NxE3R7pQOC/zoz6LVVq
	 dSnSgZ9EbCpMDg/TbxYNjbamRXbcjpoLgio0JyMs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731726AbgFRBoi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Jun 2020 21:44:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:37706 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731891AbgFRB2r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jun 2020 21:28:47 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9F7BF22226;
        Thu, 18 Jun 2020 01:28:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1592443727;
        bh=8v/jcvfIvMO4FvTNn2ccGQXv+Rodw+T1uuSu+tjYeQk=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=JPCGhA9nVw/kAHtmaU3g2vWh+3luEm1Noijs0kwJ9ZolZJnQ0tcWspZ250PSsaU3j
         xcVEmQZ61I+AxVSIXVaYrCMruL+rigiq1/lCz/lBIaWFD+rMouVmMDqs752yKh5RCA
         MhZQmuE2QnAVhY+HqmCFukjBgZo3ejV51ka8p6TE=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Xiyu Yang <xiyuyang19@fudan.edu.cn>,
        Xin Tan <tanxin.ctf@gmail.com>,
        "J . Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 22/80] nfsd: Fix svc_xprt refcnt leak when setup callback client failed
Date:   Wed, 17 Jun 2020 21:27:21 -0400
Message-Id: <20200618012819.609778-22-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200618012819.609778-1-sashal@kernel.org>
References: <20200618012819.609778-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Xiyu Yang <xiyuyang19@fudan.edu.cn>

[ Upstream commit a4abc6b12eb1f7a533c2e7484cfa555454ff0977 ]

nfsd4_process_cb_update() invokes svc_xprt_get(), which increases the
refcount of the "c->cn_xprt".

The reference counting issue happens in one exception handling path of
nfsd4_process_cb_update(). When setup callback client failed, the
function forgets to decrease the refcnt increased by svc_xprt_get(),
causing a refcnt leak.

Fix this issue by calling svc_xprt_put() when setup callback client
failed.

Signed-off-by: Xiyu Yang <xiyuyang19@fudan.edu.cn>
Signed-off-by: Xin Tan <tanxin.ctf@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/nfs4callback.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 8d842282111b..172f697864ab 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1156,6 +1156,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	err = setup_callback_client(clp, &conn, ses);
 	if (err) {
 		nfsd4_mark_cb_down(clp, err);
+		if (c)
+			svc_xprt_put(c->cn_xprt);
 		return;
 	}
 }
-- 
2.25.1

