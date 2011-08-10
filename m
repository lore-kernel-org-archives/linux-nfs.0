Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44242 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924Ab1HJVLI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 17:11:08 -0400
Received: from zenyatta.panasas.com (zenyatta.int.panasas.com [172.17.28.63])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id p7ALB6jc000572
	for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 17:11:07 -0400
Message-ID: <4E42F3E3.8050006@panasas.com>
Date: Wed, 10 Aug 2011 14:10:59 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCHSET 0/4] exofs & pnfsd-exofs assorted changes
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Submitted are, a changes to upstream exofs, and some proper fixes
to pnfsd-exofs.

the patches:
[PATCH 1/4] exofs: Remove unused data_map member from exofs_sb_info

	This patch will be put in linux-next for the 3.2 merge window

[PATCH 2/4] SQUASHME: pnfsd-exofs: Convert to ORE (2)
[PATCH 3/4] ore: Make ore_calc_stripe_info EXPORT_SYMBOL
[PATCH 4/4] pnfsd-exofs: Serve out a single group layout at a time

	These patches are for the pnfsd tree, including the ore
	one which has users only in the pnfsd tree for now.

Thanks
Boaz

