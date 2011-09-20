Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:36232 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab1ITDSu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2011 23:18:50 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/3] replacement for "introduce pnfs private workqueue"
Date: Mon, 19 Sep 2011 23:18:45 -0400
Message-Id: <1316488728-24912-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The first patch is a bug fix that has already been sent upstream.  The next
two patches should replace the following in your tree:

0359f0e pNFS: introduce pnfs private workqueue
d9b5876 SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
ef9e1a70 SQUASHME: pnfs: do pnfsiod_start before registering layout drivers

This will re-order the patches so that the bug fix is first, followed by the
workqueue patches.

These are also available on the for-benny branch of my git repo.

Benny Halevy (1):
  SQUASHME: pnfs: simplify and clean up pnfsiod workqueue

Peng Tao (2):
  pnfsblock: add missing rpc_put_mount and path_put
  pnfs: introduce pnfs private workqueue

 fs/nfs/blocklayout/blocklayout.c |   21 +++++++++++---
 fs/nfs/objlayout/objio_osd.c     |   10 ++++++-
 fs/nfs/objlayout/objlayout.c     |    4 +-
 fs/nfs/pnfs.c                    |   54 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                    |    4 +++
 5 files changed, 84 insertions(+), 9 deletions(-)

-- 
1.7.4.1

