Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33DE1C48BCF
	for <linux-nfs@archiver.kernel.org>; Sun, 13 Jun 2021 03:53:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E79A661078
	for <linux-nfs@archiver.kernel.org>; Sun, 13 Jun 2021 03:53:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231575AbhFMDzO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 12 Jun 2021 23:55:14 -0400
Received: from out20-98.mail.aliyun.com ([115.124.20.98]:44051 "EHLO
        out20-98.mail.aliyun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231537AbhFMDzO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jun 2021 23:55:14 -0400
X-Alimail-AntiSpam: AC=CONTINUE;BC=0.2167115|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_news_journal|0.00157549-0.00027822-0.998146;FP=0|0|0|0|0|-1|-1|-1;HT=ay29a033018047209;MF=wangyugui@e16-tech.com;NM=1;PH=DS;RN=2;RT=2;SR=0;TI=SMTPD_---.KRcIApQ_1623556391;
Received: from 192.168.2.112(mailfrom:wangyugui@e16-tech.com fp:SMTPD_---.KRcIApQ_1623556391)
          by smtp.aliyun-inc.com(10.147.41.231);
          Sun, 13 Jun 2021 11:53:11 +0800
Date:   Sun, 13 Jun 2021 11:53:14 +0800
From:   Wang Yugui <wangyugui@e16-tech.com>
To:     linux-nfs@vger.kernel.org
Subject: any idea about auto export multiple btrfs snapshots?
Cc:     neilb@suse.de
Message-Id: <20210613115313.BC59.409509F4@e16-tech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Mailer: Becky! ver. 2.75.04 [en]
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

Any idea about auto export multiple btrfs snapshots?

One related patch is yet not merged to nfs-utils 2.5.3.
From:   "NeilBrown" <neilb@suse.de>
Subject: [PATCH/RFC v2 nfs-utils] Fix NFSv4 export of tmpfs filesystems.

In this patch, an UUID is auto generated when a tmpfs have no UUID.

for btrfs, multiple subvolume snapshot have the same filesystem UUID.
Could we generate an UUID for btrfs subvol with 'filesystem UUID' + 'subvol ID'?

Best Regards
Wang Yugui (wangyugui@e16-tech.com)
2021/06/13


