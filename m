Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:41083 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab1IPQOW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2011 12:14:22 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/5] pnfsblock: Bug fixes for 3.1
Date: Fri, 16 Sep 2011 12:14:14 -0400
Message-Id: <1316189659-8799-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These bug fixes for the pnfs block layout driver should apply to linux 3.1.

Jim Rees (2):
  pnfsblock: fix size of upcall message
  pnfsblock: fix return code confusion

Peng Tao (3):
  pnfsblock: fix NULL pointer dereference
  pnfsblock: fix writeback deadlock
  pnfsblock: add missing rpc_put_mount and path_put

 fs/nfs/blocklayout/blocklayout.c    |   39 ++++++++++++++++++++++++----------
 fs/nfs/blocklayout/blocklayout.h    |    2 +-
 fs/nfs/blocklayout/blocklayoutdev.c |   13 +++++++----
 3 files changed, 36 insertions(+), 18 deletions(-)

-- 
1.7.6

