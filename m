Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44279 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566AbbEHI4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 04:56:40 -0400
From: NeilBrown <neilb@suse.de>
To: linux-raid@vger.kernel.org, Shaohua Li <shli@kernel.org>
Date: Fri, 08 May 2015 18:56:10 +1000
Subject: [PATCH 0/7] md fixes for -rc2
Cc: linux-nfs@vger.kernel.org
Message-ID: <20150508085345.19179.8866.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,
 following are some md fixes for -rc2 that I will be sending to Linus
 (hopefully) for -rc3.

 Most are for raid5 and many of those are fixes for the new
 batched-stripe-writes code.
 Sorry Shaohua, I didn't review/test those properly before forwarding
 them on.  Could you please check them all and make sure there is
 nothing that you disagree with.

Thanks,
NeilBrown


---

Heinz Mauelshagen (1):
      md-raid0: conditional mddev->queue access to suit dm-raid

NeilBrown (6):
      md/raid5: new alloc_stripe() to allocate an initialize a stripe.
      md/raid5: more incorrect BUG_ON in handle_stripe_fill.
      md/raid5: avoid reading parity blocks for full-stripe write to degraded array
      md/raid5: don't record new size if resize_stripes fails.
      md/raid5: fix allocation of 'scribble' array.
      md/raid5: fix handling of degraded stripes in batches.


 drivers/md/raid0.c |    5 +-
 drivers/md/raid5.c |  123 ++++++++++++++++++++++++++++++----------------------
 2 files changed, 73 insertions(+), 55 deletions(-)

--
Signature

