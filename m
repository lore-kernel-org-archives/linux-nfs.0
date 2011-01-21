Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:51857 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754387Ab1AUQxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jan 2011 11:53:15 -0500
Date: Fri, 21 Jan 2011 11:53:09 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/3] nfs-utils: blkmapd
Message-ID: <cover.1295627825.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This set of patches fixes various bugs in stripe size calculation turned up
in testing.  I believe blkmapd will now handle any layout that is allowed by
the spec and can be constructed by device-mapper.

If a striped device is not a multiple of both the number of constituent
devices and the stripe width, blkmapd will truncate the device so that
device-mapper can handle it.

Jim Rees (3):
  change device offset to signed to match the spec
  Fix calculation of stripe device and unit sizes
  Various improvements to comments and syslog messages

 utils/blkmapd/device-discovery.c |    2 -
 utils/blkmapd/device-discovery.h |    4 +-
 utils/blkmapd/device-process.c   |   50 +++++++++++++++++++------------------
 utils/blkmapd/dm-device.c        |   28 ++++++++++++++++-----
 4 files changed, 49 insertions(+), 35 deletions(-)

