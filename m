Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 321ECC282C8
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 16:03:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED4FC2082E
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 16:03:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548691404;
	bh=yFmaWr2poVHxRTrHOvuMU2owI43FRFBpVtZfhpbG61g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=KGElmPGYflwKTFReDkgD5mabRYrvUl+u2Ylo7OQNOmO+xMuio2j2o7p+bQ3nVxeUc
	 3PB3ppbnZ55TPvyRwCxQQ9btwrTc2Xvys2CnS29YXxGraagC5nT2zABFDJ5aA4caU5
	 zeoDk6uH81HrfcpOlCgK+mo2Xk6fshNUarm7b0VQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729025AbfA1QDW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jan 2019 11:03:22 -0500
Received: from mail.kernel.org ([198.145.29.99]:48664 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731371AbfA1QDU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jan 2019 11:03:20 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 215AB2175B;
        Mon, 28 Jan 2019 16:03:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1548691400;
        bh=yFmaWr2poVHxRTrHOvuMU2owI43FRFBpVtZfhpbG61g=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=AmrebvqCS7LDnqiNeK5AnLfwV/E8y5h4r683Jr6vkUxjQMNtIxT2RoCKkGeYgybqm
         rHuD6XqfKytjLWRndkJN2iq5nCd4bN9NZbFUg3BmPyMhd5q6XDI3NwtKr+GC/7/LA6
         evVKMVBm5UsgD2ZQfTjbuNC00SO0ZLWBN92hucFc=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 081/258] nfsd4: fix crash on writing v4_end_grace before nfsd startup
Date:   Mon, 28 Jan 2019 10:56:27 -0500
Message-Id: <20190128155924.51521-81-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128155924.51521-1-sashal@kernel.org>
References: <20190128155924.51521-1-sashal@kernel.org>
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
index 7fb9f7c667b1..899174c7a8ae 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1126,6 +1126,8 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
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

