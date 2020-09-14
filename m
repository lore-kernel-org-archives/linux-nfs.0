Return-Path: <SRS0=tdDw=CX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2174C43461
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 17:10:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B06B121974
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 17:10:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600103410;
	bh=4VDGPZbOkg6QfLEfi1JhpBbDvYsDwUwHOlmUDXP8ahc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=tgqv5LxYGCd71A/8w8cF77ZEw92qNFKY+5GUMdPQWrUv/ABi3hwBlVXZ2r9wulYy3
	 nRbJj8uUn/RNJF71fxA/mcwqFM7y8tyxG3XK/OjYTWNMrt1/fL8Oa3cdMVrXpw/CWW
	 u853QBHMpwc1goOssOl41rSrEN/5TY4RXHugmMx8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726112AbgINRJj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Sep 2020 13:09:39 -0400
Received: from mail.kernel.org ([198.145.29.99]:60290 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726595AbgINNEt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Sep 2020 09:04:49 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 83F26221EB;
        Mon, 14 Sep 2020 13:04:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600088654;
        bh=4VDGPZbOkg6QfLEfi1JhpBbDvYsDwUwHOlmUDXP8ahc=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Umv0NfyuB+rR8ugU9Ul9oxAHQ7CdtF7RFqIMMOI9fDJI+Qb39yb/s9seQhggk63Pp
         sjneyOGb2zkbffEPMCDNeDNOT86NUsL6gu08nGDwBQ2HTQZfa9zcgRCe6G8cyoD4/H
         60FOhTcTS0Ok+0cEJNJuoF0lShhm5BwvxCDhvup8=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.8 13/29] NFS: Zero-stateid SETATTR should first return delegation
Date:   Mon, 14 Sep 2020 09:03:42 -0400
Message-Id: <20200914130358.1804194-13-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200914130358.1804194-1-sashal@kernel.org>
References: <20200914130358.1804194-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit 644c9f40cf71969f29add32f32349e71d4995c0b ]

If a write delegation isn't available, the Linux NFS client uses
a zero-stateid when performing a SETATTR.

NFSv4.0 provides no mechanism for an NFS server to match such a
request to a particular client. It recalls all delegations for that
file, even delegations held by the client issuing the request. If
that client happens to hold a read delegation, the server will
recall it immediately, resulting in an NFS4ERR_DELAY/CB_RECALL/
DELEGRETURN sequence.

Optimize out this pipeline bubble by having the client return any
delegations it may hold on a file before it issues a
SETATTR(zero-stateid) on that file.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7f337188a2829..08b1fb0a9225a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3272,8 +3272,10 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 	/* Servers should only apply open mode checks for file size changes */
 	truncate = (arg->iap->ia_valid & ATTR_SIZE) ? true : false;
-	if (!truncate)
+	if (!truncate) {
+		nfs4_inode_make_writeable(inode);
 		goto zero_stateid;
+	}
 
 	if (nfs4_copy_delegation_stateid(inode, FMODE_WRITE, &arg->stateid, &delegation_cred)) {
 		/* Use that stateid */
-- 
2.25.1

