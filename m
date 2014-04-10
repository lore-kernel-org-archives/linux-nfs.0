Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:34552
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965541AbaDJKqT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 06:46:19 -0400
Message-ID: <53467667.3010304@panasas.com>
Date: Thu, 10 Apr 2014 13:45:59 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>,
        Daniel Gryniewicz <dang@linuxbox.com>,
        Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>,
        "Pathak, Santosh" <santoshp@panasas.com>
CC: Benny Halevy <bhalevy@primarydata.com>,
        Sachin bhamare <sachin.bhamare@gmail.com>
Subject: [RFC 0/3] ore: raid6
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all

proud to present some experimentation with raid6 in ORE.

These simple patches will enable raid6 using the Kernel's raid6_pq engine
for support under exofs and pnfs-objects. There is nothing needed to do
at exofs and pnfs-obj. Just fire your mkfs.exofs with --raid=6 (that was
already supported before) and off you go as usual. The ORE will pick up
the new map and will start writing two devices of redundancy bits.

Very RFC right now. Only lightly tested. Git clone linux and compile.
Only a very few parameters tested:
	group_width=5 && group_width=6 s_unit=4*PAGES && s_unit=1*PAGE
Please have a try, report all the crashes.

In the next iteration I would like to add some raid6-math documentation
which I think is needed for completeness.

I want to deeply thank Daniel Gryniewicz who found first all the
bugs in the old raid code, and inspired these patches.

list of patches:
[PATCH 1/4] ore: (trivial) reformat some code
[PATCH 2/4] ore: Remove redundant dev_order(), more cleanups
[PATCH 3/4] ore: Support for raid 6

Cheers
Boaz
