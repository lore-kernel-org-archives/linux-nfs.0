Return-Path: <SRS0=2npy=77=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9680C433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jun 2020 02:28:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7D75A2192A
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jun 2020 02:28:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1592447291;
	bh=Il+45iujVCYEqM5m6qUHQmdBDfODZnNhkilSBuA698g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=ZeV2FIKDEudC28MqNK6QntMWsJbL2lQdhF3pKEIadOZbenA2DCMRGNGPsFr/5vMl0
	 lJLR/kTHanc+oH/R/EZ3vzgDrPyQe4wuTh6BQbd04aI3zdzQEaJuDAZ4KcCrF3P5/+
	 tmXWiWs0PsRgz3Wlw8XcU26guA8gzWW9ZA+xlpqE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728775AbgFRBQ1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Jun 2020 21:16:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:46498 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728503AbgFRBQT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jun 2020 21:16:19 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 94565206F1;
        Thu, 18 Jun 2020 01:16:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1592442979;
        bh=Il+45iujVCYEqM5m6qUHQmdBDfODZnNhkilSBuA698g=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=FEVSBByQ2cWOjSfASPgx2tKY2JMj3drUnppnVLGC63TV1FZrvMGZ4fynMFL9DyXdr
         AVZ3xV6HzY0KUSivqbz9k5PEsrDxPd0HiUgp1iMFwecrHgjEfHB+tDah/XdirmWW8A
         HCTZ8hwPvqWD0QRRms1U7E4z8cyYP2etxr7BLZrY=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.7 381/388] NFS: Fix direct WRITE throughput regression
Date:   Wed, 17 Jun 2020 21:07:58 -0400
Message-Id: <20200618010805.600873-381-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200618010805.600873-1-sashal@kernel.org>
References: <20200618010805.600873-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit ba838a75e73f55a780f1ee896b8e3ecb032dba0f ]

I measured a 50% throughput regression for large direct writes.

The observed on-the-wire behavior is that the client sends every
NFS WRITE twice: once as an UNSTABLE WRITE plus a COMMIT, and once
as a FILE_SYNC WRITE.

This is because the nfs_write_match_verf() check in
nfs_direct_commit_complete() fails for every WRITE.

Buffered writes use nfs_write_completion(), which sets req->wb_verf
correctly. Direct writes use nfs_direct_write_completion(), which
does not set req->wb_verf at all. This leaves req->wb_verf set to
all zeroes for every direct WRITE, and thus
nfs_direct_commit_completion() always sets NFS_ODIRECT_RESCHED_WRITES.

This fix appears to restore nearly all of the lost performance.

Fixes: 1f28476dcb98 ("NFS: Fix O_DIRECT commit verifier handling")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/direct.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a57e7c72c7f4..d49b1d197908 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -731,6 +731,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		nfs_list_remove_request(req);
 		if (request_commit) {
 			kref_get(&req->wb_kref);
+			memcpy(&req->wb_verf, &hdr->verf.verifier,
+			       sizeof(req->wb_verf));
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
 				hdr->ds_commit_idx);
 		}
-- 
2.25.1

