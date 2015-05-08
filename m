Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56810 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907AbbEHAuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 20:50:16 -0400
From: NeilBrown <neilb@suse.de>
To: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Date: Fri, 08 May 2015 10:16:23 +1000
Subject: [PATCH 0/3] make BTRFS, UDF, NILFS2 work with NFSv2.
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Message-ID: <20150508001142.31129.7604.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi filesystem folks,
 I just had a report that BTRFS doesn't work reliably with NFSv2.

 The problem is that NFSv2 doesn't encode filehandle size so it may
 report to the filesystem a longer handle that is being expected.

 Filesystems should not require a specific length, only at least that
 length.

 A code audit shows that NILFS2 and UDF suffer the same problem.

 Following patches should fix it... well, they compile and look good.

 Please consider for inclusion is respective trees.


 Admittedly NFSv2 is a bit "last century", but while it is easy to
 support, we may as well.

Thanks,
NeilBrown


---

NeilBrown (3):
      BTRFS: support NFSv2 export
      NILFS2: support NFSv2 export
      UDF: support NFSv2 export


 fs/btrfs/export.c |   10 +++++-----
 fs/nilfs2/namei.c |    6 +++---
 fs/udf/namei.c    |   16 ++++++++++++----
 3 files changed, 20 insertions(+), 12 deletions(-)

--
Signature

