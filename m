Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60740 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab2HCIIh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Aug 2012 04:08:37 -0400
Message-ID: <501B86F3.5060507@panasas.com>
Date: Fri, 3 Aug 2012 11:08:19 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Artem Bityutskiy <artem.bityutskiy@linux.intel.com>
Subject: [GIT PULL] exofs: Mostly fixes
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus

Please pull a few changes since commit v3.5-rc5-5-gc999ff6

They are available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus

for you to fetch changes up to 9e62bb4458ad2cf28bd701aa5fab380b846db326:

  ore: Fix out-of-bounds access in _ios_obj() (2012-08-02 16:41:56 +0300)

They are all mostly fixes, except the most important patch by Artem Bityutskiy
which removes the use of s_dirt. After this patch s_dirt can be completely
removed from the tree.

Thanks, hope you are enjoying the Olympics, for me it's the swimming
Boaz

----------------------------------------------------------------
Artem Bityutskiy (1):
      exofs: stop using s_dirt

Boaz Harrosh (3):
      exofs: Fix __r4w_get_page when offset is beyond i_size
      exofs: Use proper max_IO calculations from ore
      ore: Fix out-of-bounds access in _ios_obj()

Kautuk Consul (1):
      exofs: readpage_strip: Add a BUG_ON to check for PageLocked(page)

 fs/exofs/inode.c | 27 ++++++++++++++++++---------
 fs/exofs/ore.c   | 14 +++++++-------
 fs/exofs/super.c | 11 -----------
 3 files changed, 25 insertions(+), 27 deletions(-)
