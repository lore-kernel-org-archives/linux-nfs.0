Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:40743 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab1ITDXr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2011 23:23:47 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/3] three bug fixes
Date: Mon, 19 Sep 2011 23:23:42 -0400
Message-Id: <1316489025-24991-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch set fixes three bugs found in pnfsblock testing.

Peng Tao (3):
  pnfsblock: fix NULL pointer dereference
  pnfsblock: fix writeback deadlock
  nfs4: serialize layoutcommit

 fs/nfs/blocklayout/blocklayout.c |   11 +++++++++--
 fs/nfs/nfs4proc.c                |    6 ++++++
 fs/nfs/pnfs.c                    |   24 +++++++++++++++++++++---
 include/linux/nfs_fs.h           |    1 +
 4 files changed, 37 insertions(+), 5 deletions(-)

-- 
1.7.4.1

