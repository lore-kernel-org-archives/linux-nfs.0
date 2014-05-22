Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:57487
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752362AbaEVNFD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 09:05:03 -0400
Message-ID: <537DF5B4.4070001@panasas.com>
Date: Thu, 22 May 2014 16:03:48 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>,
        Daniel Gryniewicz <dang@linuxbox.com>,
        Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>,
        "Pathak, Santosh" <santoshp@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
CC: Benny Halevy <bhalevy@primarydata.com>,
        Sachin bhamare <sachin.bhamare@gmail.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PACHSET 0/3] ore: raid6
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all

proud to present support for raid6 in ORE.

changes since RFC:
  Nothing changed. one checkpatch fix. And this time all patches actually
  compile (thanks to Tigran)

  I have by now tested better. RAID6 code was not actually tested heavily
  but RAID5 was, and there are no known regressions to RAID5 so I'm pushing
  this for next merge.
  .I.E: Yes I did run all tests on RAID6 but user-mode utils do not support
      scrubbing and checking of RAID6 yet. So I'm not confident that it is
      100% cosher. But I do have a XOR checker and RAID5 is just as good as
      current code. So I'm pushing this now and any RAID6 specific problems
      can be fixed when they are found.

These simple patches will enable raid6 using the Kernel's raid6_pq engine
for support under exofs and pnfs-objects. There is nothing needed to do
at exofs and pnfs-obj. Just fire your mkfs.exofs with --raid=6 (that was
already supported before) and off you go as usual. The ORE will pick up
the new map and will start writing two devices of redundancy bits.
Including the pNFS server code and pnfs-export bits at exofs, they all
work supporting raid6 without any code modifications.

I want to deeply thank Daniel Gryniewicz who found first all the
bugs in the old raid code, and inspired these patches.

list of patches:
[PATCH 1/4] ore: (trivial) reformat some code
[PATCH 2/4] ore: Remove redundant dev_order(), more cleanups
[PATCH 3/4] ore: Support for raid 6

Cheers
Boaz
