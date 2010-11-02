Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:45755 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab0KBUJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 16:09:17 -0400
Date: Tue, 2 Nov 2010 16:08:24 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/6] nfs-utils: Cumulative patches for blkmapd
Message-ID: <cover.1288726186.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Cumulative patches for blkmapd.

Jim Rees (6):
  blkmapd: get rid of config file and instead examine all block devices
  blkmapd: don't rescan periodically
  blkmapd: don't use atomicio() where it's not needed
  ignore passive devices before checking serial numbers
  add "-d" option to just do discovery then exit
  Various bug fixes and cleanups.

 utils/blkmapd/Makefile.am        |    3 -
 utils/blkmapd/atomicio.c         |   54 --------
 utils/blkmapd/cfg.c              |  248 --------------------------------------
 utils/blkmapd/cfg.h              |   47 -------
 utils/blkmapd/device-discovery.c |  216 +++++++++++++++------------------
 utils/blkmapd/device-discovery.h |    5 +-
 utils/blkmapd/device-inq.c       |   43 +++----
 utils/blkmapd/device-process.c   |   30 ++---
 utils/blkmapd/dm-device.c        |    1 +
 9 files changed, 129 insertions(+), 518 deletions(-)
 delete mode 100644 utils/blkmapd/atomicio.c
 delete mode 100644 utils/blkmapd/cfg.c
 delete mode 100644 utils/blkmapd/cfg.h

