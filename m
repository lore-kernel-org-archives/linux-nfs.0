Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ABE1C47088
	for <linux-nfs@archiver.kernel.org>; Wed, 26 May 2021 17:34:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E6EC2613C7
	for <linux-nfs@archiver.kernel.org>; Wed, 26 May 2021 17:34:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234417AbhEZRfd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 May 2021 13:35:33 -0400
Received: from smtp-out2.suse.de ([195.135.220.29]:51364 "EHLO
        smtp-out2.suse.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234386AbhEZRfc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2021 13:35:32 -0400
Received: from imap.suse.de (imap-alt.suse-dmz.suse.de [192.168.254.47])
        (using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 90C581FD2A;
        Wed, 26 May 2021 17:25:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1622049910; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=TH5m+itfc3wszX6zdthSUNY7BimLXL7cWZygJJRHBR0=;
        b=RN3tFcMuIcqKlN9AOxzBvmYZAfpSKsenkVf8lyC47W9dl0QU0sO8HEns97Qbsc4HkkbU7o
        0hjKDqaqeZkfqRGX2YQ9ucKRFTfpt1okviTaKdldcYoi5uwWQ5/5NUQr6/LiNmoowFKBG3
        8cWIRDuzIjctoEOYk2znmISFLZjRPVs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1622049910;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=TH5m+itfc3wszX6zdthSUNY7BimLXL7cWZygJJRHBR0=;
        b=IcV7JQauHTEfXp01mWLATdPGZuUGnn2vtuAuihYj+5VbJOvV/agEiyo4demwFvD2vUo70c
        2dIKS22GA8SRe8CA==
Received: from director2.suse.de (director2.suse-dmz.suse.de [192.168.254.72])
        by imap.suse.de (Postfix) with ESMTPSA id 6F33611A98;
        Wed, 26 May 2021 17:25:10 +0000 (UTC)
From:   Petr Vorel <pvorel@suse.cz>
To:     ltp@lists.linux.it
Cc:     Petr Vorel <pvorel@suse.cz>,
        Alexey Kodanev <aleksei.kodanev@bell-sw.com>,
        linux-nfs@vger.kernel.org
Subject: [LTP PATCH v2 1/3] nfs_lib.sh: Detect unsupported protocol
Date:   Wed, 26 May 2021 19:25:01 +0200
Message-Id: <20210526172503.18621-1-pvorel@suse.cz>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Caused by disabled CONFIG_NFSD_V[34] in kernel config.

Signed-off-by: Petr Vorel <pvorel@suse.cz>
---
new in v2

 testcases/network/nfs/nfs_stress/nfs_lib.sh | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/testcases/network/nfs/nfs_stress/nfs_lib.sh b/testcases/network/nfs/nfs_stress/nfs_lib.sh
index 3fad8778a..b80ee0e18 100644
--- a/testcases/network/nfs/nfs_stress/nfs_lib.sh
+++ b/testcases/network/nfs/nfs_stress/nfs_lib.sh
@@ -94,9 +94,15 @@ nfs_mount()
 
 	if [ $? -ne 0 ]; then
 		cat mount.log
+
 		if [ "$type" = "udp" -o "$type" = "udp6" ] && tst_kvcmp -ge 5.6; then
 			tst_brk TCONF "UDP support disabled with the kernel config NFS_DISABLE_UDP_SUPPORT?"
 		fi
+
+		if grep -i "Protocol not supported" mount.log; then
+			tst_brk TCONF "Protocol not supported"
+		fi
+
 		tst_brk TBROK "mount command failed"
 	fi
 }
-- 
2.31.1

