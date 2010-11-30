Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60005 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab0K3TNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 14:13:22 -0500
Date: Tue, 30 Nov 2010 14:13:20 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/5] nfs-utils: various changes
Message-ID: <cover.1291142529.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This series incorporates fixes to the block layout daemon from the last few
weeks of testing.

The first two patches I sent before, and I think they are in one of the tags
but they don't seem to have made it to origin/master.

The rest are split into three categories, disk signature fixes, device
mapping fixes, and cleanups.  I would be happy to split these up into
smaller chunks, but I think it's maybe a bit easier to review this way.

Jim Rees (5):
  add blkmapd and spnfsd to list of build targets to ignore
  Remove blkmapd config file, which is no longer used.
  disk signature fixes
  various minor cleanups
  device mapping fixes

 .gitignore                       |    2 +
 utils/blkmapd/device-discovery.c |   17 ++--
 utils/blkmapd/device-discovery.h |   11 +-
 utils/blkmapd/device-inq.c       |    7 +-
 utils/blkmapd/device-process.c   |  153 +++++++++++++++------------
 utils/blkmapd/dm-device.c        |  209 +++++++++++++++++++------------------
 utils/blkmapd/etc/blkmapd.conf   |   10 --
 7 files changed, 211 insertions(+), 198 deletions(-)
 delete mode 100644 utils/blkmapd/etc/blkmapd.conf

