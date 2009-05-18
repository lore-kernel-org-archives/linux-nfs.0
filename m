From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two more nfs-utils patches
Date: Mon, 18 May 2009 12:12:53 -0400
Message-ID: <20090518161224.12029.86761.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:18656 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758369AbZERQPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 12:15:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve-

While you're at it, here are two more fixes.

---

Chuck Lever (2):
      umount.nfs: Harden umount.nfs error reporting
      nfs-utils: Fix IPv6 support in support/nfs/rpc_socket.c


 support/nfs/rpc_socket.c |   12 +++++-------
 utils/mount/network.c    |   19 ++++++++++++++-----
 utils/mount/nfsumount.c  |   17 +++++++++--------
 3 files changed, 28 insertions(+), 20 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
