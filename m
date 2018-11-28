Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0B43C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 15:06:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7C7AB208E7
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 15:06:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C7AB208E7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=codethink.co.uk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728141AbeK2CIC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 21:08:02 -0500
Received: from imap1.codethink.co.uk ([176.9.8.82]:55739 "EHLO
        imap1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727726AbeK2CIC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 21:08:02 -0500
Received: from office.codethink.co.uk ([148.252.241.226] helo=devhw0)
        by imap1.codethink.co.uk with esmtpsa (Exim 4.84_2 #1 (Debian))
        id 1gS1Pb-0004yv-Se; Wed, 28 Nov 2018 15:05:59 +0000
Received: from tpreston by devhw0 with local (Exim 4.89)
        (envelope-from <thomas.preston@codethink.co.uk>)
        id 1gS1Pb-0002TA-4x; Wed, 28 Nov 2018 15:05:59 +0000
From:   Thomas Preston <thomas.preston@codethink.co.uk>
To:     anna.schumaker@netapp.com, jlayton@kernel.org,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Cc:     linux-kernel@lists.codethink.co.uk,
        Thomas Preston <thomas.preston@codethink.co.uk>
Subject: [PATCH v2 0/1] SUNRPC: Allow /proc entries without CONFIG_SUNRPC_DEBUG
Date:   Wed, 28 Nov 2018 15:05:57 +0000
Message-Id: <20181128150558.9455-1-thomas.preston@codethink.co.uk>
X-Mailer: git-send-email 2.11.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,
We have a patch which adds sunrpc /proc entries without having to enable the
full SUNRPC debug, which we found useful. Tested on NVIDIA Tegra30.

Changes since v1:
- Non-debug /proc/sys/sunrpc entries are always enabled.

Ben Dooks (1):
  SUNRPC: allow /proc entries without CONFIG_SUNRPC_DEBUG

 net/sunrpc/xprtsock.c | 8 --------
 1 file changed, 8 deletions(-)

-- 
2.11.0

