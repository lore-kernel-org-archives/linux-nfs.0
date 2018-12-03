Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8575DC64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:58:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 528F120881
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:58:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 528F120881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725838AbeLCA6t (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:58:49 -0500
Received: from mx2.suse.de ([195.135.220.15]:43054 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCA6t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:58:49 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id EECF9ADC9;
        Mon,  3 Dec 2018 00:58:42 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Mon, 03 Dec 2018 11:58:24 +1100
Subject: [PATCH 0/3] Three little nfs-utils fixes.
Cc:     Justin Mitchell <jumitche@rehat.com>, linux-nfs@vger.kernel.org
Message-ID: <154379862296.3215.11174339731963464375.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

First fixes a regression I found when importing the latest upstream at
SUSE.

Others are related to ensuring systemd starts thing properly in cases
that hadn't been tested before.

Thanks,
NeilBrown


---

NeilBrown (3):
      nfs.conf: allow empty assignments.
      Let systemd know when rpc.statd is needed.
      systemd: run statd-notify even when nfs-client isn't enabled.


 support/nfs/conffile.c      |    5 -----
 systemd/rpc-statd.service   |    1 +
 tests/nfsconf/01-errors.exp |    1 -
 utils/statd/start-statd     |    7 ++++++-
 4 files changed, 7 insertions(+), 7 deletions(-)

--
Signature

