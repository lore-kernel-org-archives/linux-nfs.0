Return-Path: <SRS0=Jjwl=XS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 185E4C4740C
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 04:27:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EC3CF20820
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 04:27:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2406612AbfIWE12 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Sep 2019 00:27:28 -0400
Received: from mx2.suse.de ([195.135.220.15]:47300 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2405826AbfIWE12 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Sep 2019 00:27:28 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 3A0BDAFA4;
        Mon, 23 Sep 2019 04:27:27 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Mon, 23 Sep 2019 14:26:57 +1000
Subject: [PATCH 0/3] some nfs-utils patches.
Cc:     linux-nfs@vger.kernel.org
Message-ID: <156921267783.27519.2402857390317412450.stgit@noble.brown>
User-Agent: StGit/0.19
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These free are largely unrelated.
The only connection is that without the second, I get
warnings because my /etc/nfs.conf includes /etc/nfs.conf.local - just
in case.
Then, without the first patch, the open fds get confused and
rpc.mountd doesn't listen on all /proc/net/rpc/*/channel
properly and nfs doesn't work.

Thanks,
NeilBrown

---

NeilBrown (3):
      mountd: Initialize logging early.
      conffile: allow optional include files.
      statd: take user-id from /var/lib/nfs/sm


 support/nfs/conffile.c    |   13 ++++++++++---
 support/nsm/file.c        |   16 +++++-----------
 systemd/nfs.conf.man      |    3 +++
 utils/mountd/mountd.c     |    9 +++------
 utils/statd/sm-notify.man |   10 +++++++++-
 utils/statd/statd.man     |   10 +++++++++-
 6 files changed, 39 insertions(+), 22 deletions(-)

--
Signature

