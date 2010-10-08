Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60200 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757014Ab0JHQGn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 12:06:43 -0400
Date: Fri, 8 Oct 2010 12:06:33 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, sfaibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/4] nfs-utils: rework device scanning in blkmapd
Message-ID: <cover.1286552019.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This series reworks the way device scanning is done in blkmapd as a result
of test results and discussions at the Fall 2010 Bakeathon.

We get rid of the config file and instead examine all block devices as
listed in /sys/block and /proc/partitions (this is the way fdisk does it).
Since we're looking for pnfs signatures, it usually doesn't hurt to examine
a device that isn't part of a layout, and in general it's hard to tell ahead
of time which devices should be considered, so I think having a config file
does more harm than good.

We get rid of periodic (once a minute) device rescanning, and instead rescan
only when the kernel asks for a layout.  This will suffice for the common
case, and works with all current known server implementations.  A later
patch will re-introduce rescanning during the life of a layout, but will be
triggered by configuration change notifications from udev, rather than by
expiration of an arbitrary time interval.

We get rid of the test for active/passive devices.  This test really only
works for EMC servers, and isn't even needed because the passive devices
will be skipped over during signature detection.  Just remove the detection
code.

Jim Rees (4):
  blkmapd: get rid of config file and instead examine all block devices
  blkmapd: don't rescan periodically
  blkmapd: don't use atomicio() where it's not needed
  blkmapd: don't try to distinguish between active/passive devices

 utils/blkmapd/Makefile.am        |    2 -
 utils/blkmapd/cfg.c              |  248 --------------------------------------
 utils/blkmapd/cfg.h              |   47 -------
 utils/blkmapd/device-discovery.c |  141 ++++++++--------------
 utils/blkmapd/device-discovery.h |    3 -
 utils/blkmapd/device-inq.c       |   40 ++-----
 utils/blkmapd/device-process.c   |    2 +-
 7 files changed, 60 insertions(+), 423 deletions(-)
 delete mode 100644 utils/blkmapd/cfg.c
 delete mode 100644 utils/blkmapd/cfg.h

