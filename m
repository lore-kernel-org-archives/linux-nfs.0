Return-Path: <SRS0=XrmD=6O=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 506D9C28CBC
	for <linux-nfs@archiver.kernel.org>; Thu, 30 Apr 2020 13:58:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1D4B4206D9
	for <linux-nfs@archiver.kernel.org>; Thu, 30 Apr 2020 13:58:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1588255127;
	bh=2y5orJ/2p1rH66TWBTgBpCZq6mWOcZBuWtjq0rNcpA4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=jsQa0kbsOC05oAp3bd18AplwK1e+c5IH2KZpjQ/1D6FIdYaNbQ18jlI+EJaPCKf9T
	 wpK2/tVI/hH9SCKw7MeXXeb8XHK8yPeGoGcS6DfyNqPntBYbd6LEqj0pw5+DcRO6RU
	 tpSIntVVna06hQAHGryYaU0T5Ynx7zt7ty+9gBaY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728276AbgD3N6p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 30 Apr 2020 09:58:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:37190 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729011AbgD3Nyh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Apr 2020 09:54:37 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1390D20870;
        Thu, 30 Apr 2020 13:54:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1588254876;
        bh=2y5orJ/2p1rH66TWBTgBpCZq6mWOcZBuWtjq0rNcpA4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=zBqibr8BMQg7XZ0KbqHjquzxCgSGtvfVCucsAMPmywRHkZvD3tgpRmUYjU0Jp9HCg
         9PwpZBOsf4gOaq9xRS4/YOuzKeJ0OL6y1p8NWRdUiwyAC65v+hWB2s6EiFLPVEwFZQ
         oxY7ZGAb5obHHiVs8OendMJ5r4p/UrbiaepujrUA=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Vasily Averin <vvs@virtuozzo.com>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 02/17] nfsd: memory corruption in nfsd4_lock()
Date:   Thu, 30 Apr 2020 09:54:18 -0400
Message-Id: <20200430135433.21204-2-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200430135433.21204-1-sashal@kernel.org>
References: <20200430135433.21204-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Vasily Averin <vvs@virtuozzo.com>

[ Upstream commit e1e8399eee72e9d5246d4d1bcacd793debe34dd3 ]

New struct nfsd4_blocked_lock allocated in find_or_allocate_block()
does not initialized nbl_list and nbl_lru.
If conflock allocation fails rollback can call list_del_init()
access uninitialized fields and corrupt memory.

v2: just initialize nbl_list and nbl_lru right after nbl allocation.

Fixes: 76d348fadff5 ("nfsd: have nfsd4_lock use blocking locks for v4.1+ lock")
Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4509c76716e36..5c9231d5e14a0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -246,6 +246,8 @@ find_or_allocate_block(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
 	if (!nbl) {
 		nbl= kmalloc(sizeof(*nbl), GFP_KERNEL);
 		if (nbl) {
+			INIT_LIST_HEAD(&nbl->nbl_list);
+			INIT_LIST_HEAD(&nbl->nbl_lru);
 			fh_copy_shallow(&nbl->nbl_fh, fh);
 			locks_init_lock(&nbl->nbl_lock);
 			nfsd4_init_cb(&nbl->nbl_cb, lo->lo_owner.so_client,
-- 
2.20.1

