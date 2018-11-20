Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D811C46463
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 18:22:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 65D2620684
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 18:22:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65D2620684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=codethink.co.uk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726135AbeKUEwq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 23:52:46 -0500
Received: from imap1.codethink.co.uk ([176.9.8.82]:39504 "EHLO
        imap1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725998AbeKUEwq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 23:52:46 -0500
Received: from [148.252.241.226] (helo=devhw0)
        by imap1.codethink.co.uk with esmtpsa (Exim 4.84_2 #1 (Debian))
        id 1gPAf7-0006J6-4r; Tue, 20 Nov 2018 18:22:13 +0000
Received: from tpreston by devhw0 with local (Exim 4.89)
        (envelope-from <thomas.preston@codethink.co.uk>)
        id 1gPAJ9-0007Fu-VM; Tue, 20 Nov 2018 17:59:32 +0000
From:   Thomas Preston <thomas.preston@codethink.co.uk>
To:     anna.schumaker@netapp.com, jlayton@kernel.org,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Cc:     ts001-upstream@lists.codethink.co.uk,
        Thomas Preston <thomas.preston@codethink.co.uk>
Subject: [PATCH 0/1] SUNRPC: Allow /proc entries without CONFIG_SUNRPC_DEBUG
Date:   Tue, 20 Nov 2018 17:59:29 +0000
Message-Id: <20181120175930.27853-1-thomas.preston@codethink.co.uk>
X-Mailer: git-send-email 2.11.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,
We have a patch which adds sunrpc /proc entries without having to enable the
full SUNRPC debug, which we found useful. Tested on NVIDIA Tegra30.

Many thanks,
Thomas

Ben Dooks (1):
  SUNRPC: allow /proc entries without CONFIG_SUNRPC_DEBUG

 net/sunrpc/Kconfig    | 7 +++++++
 net/sunrpc/xprtsock.c | 6 +++---
 2 files changed, 10 insertions(+), 3 deletions(-)

-- 
2.11.0

