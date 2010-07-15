Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47768 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753395Ab0GOTk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 15:40:56 -0400
Date: Thu, 15 Jul 2010 15:40:55 -0400
From: Jim Rees <rees@umich.edu>
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] pnfs-block: move device mapping from kernel to user
 daemon
Message-ID: <cover.1279221394.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These two patches move the complex block layout device mapping from the
kernel to a user space daemon.  The first patch adds a simple upcall
mechanism via pipefs for the kernel piece to communicate with the daemon.
The second patch removes the kernel device mapping and replaces it with
calls to the daemon.

Passes Connectathon tests to both EMC and spnfs servers.

The user daemon will be sent separately as a patch to nfs-utils.

Haiying Tang (2):
  pnfs-block: Add support for simple rpc pipefs
  pnfs-block: Remove device creation from kernel

 fs/nfs/blocklayout/Makefile                      |    2 +-
 fs/nfs/blocklayout/block-device-discovery-pipe.c |   66 +++
 fs/nfs/blocklayout/blocklayout.c                 |   15 +-
 fs/nfs/blocklayout/blocklayout.h                 |   18 +-
 fs/nfs/blocklayout/blocklayoutdev.c              |  494 +++-------------------
 fs/nfs/blocklayout/blocklayoutdm.c               |  297 ++-----------
 include/linux/sunrpc/rpc_pipe_fs.h               |    4 +
 include/linux/sunrpc/simple_rpc_pipefs.h         |  112 +++++
 net/sunrpc/Makefile                              |    2 +-
 net/sunrpc/simple_rpc_pipefs.c                   |  422 ++++++++++++++++++
 10 files changed, 720 insertions(+), 712 deletions(-)
 create mode 100644 fs/nfs/blocklayout/block-device-discovery-pipe.c
 create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
 create mode 100644 net/sunrpc/simple_rpc_pipefs.c

