Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97303C282C8
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 16:49:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5B6472171F
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 16:49:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548694142;
	bh=IkR1cpOsIkNUd61vaMLNjGox/eGTRczfkH7JFvyahUw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=nlWuRD0ktv4/RXBvSF8vfFHFgx251FcKc31ptyUuPJWrHNfxdJfSR2P7bfOIWo80R
	 Lzot53EIR2/snddRabTY1m3S1ljpDkKt3TNX672fZMKGZ8X+xNLAt4qjpZTKNR1Eyd
	 t0A5WCP4AK5Dws3B5iF+poGPF+Dt4IQsBYP9BDbI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387824AbfA1QVJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jan 2019 11:21:09 -0500
Received: from mail.kernel.org ([198.145.29.99]:56834 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388961AbfA1QVI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jan 2019 11:21:08 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E43072084A;
        Mon, 28 Jan 2019 16:21:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1548692468;
        bh=IkR1cpOsIkNUd61vaMLNjGox/eGTRczfkH7JFvyahUw=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=oLamOdTDpZd1vnDcGhikc8Vie7oEaBTRBUdFKrBhXpYZ2eyTW1XdCF4+nci6T6irg
         jwy1bD0vDkvDVkVZrQw0M5BPEAHABnMcNqdN04drphPo8aWIVDRQZ25t28nE+pcFUE
         XSPpDx1F5QfcWs3sZTp4OtA7bUTVvP7pjlKXGnyE=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 031/107] nfsd4: fix crash on writing v4_end_grace before nfsd startup
Date:   Mon, 28 Jan 2019 11:18:31 -0500
Message-Id: <20190128161947.57405-31-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128161947.57405-1-sashal@kernel.org>
References: <20190128161947.57405-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit 62a063b8e7d1db684db3f207261a466fa3194e72 ]

Anatoly Trosinenko reports that this:

1) Checkout fresh master Linux branch (tested with commit e195ca6cb)
2) Copy x84_64-config-4.14 to .config, then enable NFS server v4 and build
3) From `kvm-xfstests shell`:

results in NULL dereference in locks_end_grace.

Check that nfsd has been started before trying to end the grace period.

Reported-by: Anatoly Trosinenko <anatoly.trosinenko@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/nfsctl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 36b2af931e06..797a155c9a67 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1103,6 +1103,8 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
 		case 'Y':
 		case 'y':
 		case '1':
+			if (nn->nfsd_serv)
+				return -EBUSY;
 			nfsd4_end_grace(nn);
 			break;
 		default:
-- 
2.19.1

