Return-Path: <SRS0=2HRz=3F=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F2BC33CB3
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jan 2020 19:05:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F205022525
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jan 2020 19:05:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579201538;
	bh=Z2cuzGhZiehtPD1idTVQTGEo+8cKbQOQw5EZSqU/6p8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=y59A3LKaeH2XB5zyT26s4vDf3hd9+K2G4G2C3d327XmKmwTs0jvEzU4mxlNuilO/D
	 PymTT7sncrNJUnHXjHGykLpQIIWFkHm0dHLIIj30I/DalhE0w7j/RZxrCCBKkXBr6i
	 5PM8QjEPIIHuZzMRbehdpRKyuvsuz8zBFNMPsLjM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387944AbgAPTFd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Jan 2020 14:05:33 -0500
Received: from mail.kernel.org ([198.145.29.99]:53688 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388205AbgAPRBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Jan 2020 12:01:52 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E4D572077B;
        Thu, 16 Jan 2020 17:01:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1579194112;
        bh=Z2cuzGhZiehtPD1idTVQTGEo+8cKbQOQw5EZSqU/6p8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Cvkf8g/Jf9nahiWs20GCq8XhmNpUal342cHqsHNNudCqL7E8j2QJojaI/7NOgKua/
         0ckbGBtr2/G4i0h6MPKiIZyHETqbXo1hxuSGsAVyKYXwSBs/dJ6ASNWJS3ntzewmpw
         AWmEmweFzcTRrJZwrUsIVylPxqMXUN6Gl+vl7oL8=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "Eric W. Biederman" <ebiederm@xmission.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 208/671] fs/nfs: Fix nfs_parse_devname to not modify it's argument
Date:   Thu, 16 Jan 2020 11:51:57 -0500
Message-Id: <20200116165940.10720-91-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200116165940.10720-1-sashal@kernel.org>
References: <20200116165940.10720-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

[ Upstream commit 40cc394be1aa18848b8757e03bd8ed23281f572e ]

In the rare and unsupported case of a hostname list nfs_parse_devname
will modify dev_name.  There is no need to modify dev_name as the all
that is being computed is the length of the hostname, so the computed
length can just be shorted.

Fixes: dc04589827f7 ("NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d90efdea9fbd..5db7aceb4190 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1930,7 +1930,7 @@ static int nfs_parse_devname(const char *dev_name,
 		/* kill possible hostname list: not supported */
 		comma = strchr(dev_name, ',');
 		if (comma != NULL && comma < end)
-			*comma = 0;
+			len = comma - dev_name;
 	}
 
 	if (len > maxnamlen)
-- 
2.20.1

