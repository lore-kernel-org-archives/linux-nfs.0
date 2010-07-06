Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366Ab0GFURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 16:17:14 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] cleanup inode.c and bug fixes
Date: Tue,  6 Jul 2010 17:16:57 -0400
Message-Id: <1278451022-2889-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


For the pnfs-submit branch 2.6.35-rc3 7-6-2010 tree.

These first three patches simplify the inode.c pnfs initialization calls.
0001-SQUASHME-pnfs-submit-remove-pnfs_init_once.patch
0002-SQUASHME-pnfs-submit-remove-pnfs_alloc_init_inode.patch
0003-SQUASHME-pnfs-submit-remove-pnfs_destroy_inode.patch

These two patches fix bugs in the layoutget and layoutcommit error handling
where the calldata->status was not set after the async error handler in the
rpc_call_done routines.

0004-SQUASHME-pnfs-submit-set-layoutcommit-status-after-a.patch
0005-SQUASHME-pnfs-submit-set-layoutget-status-after-asyn.patch

Tested:
CONFIG_NFS_V4_1 set:

pNFS mount connectathon tests pass.
pyNFS server with NFS4ERR_DELAY returned by layoutget handles the error in
the async error handler, and then the calldata->status is set to NFS4_OK.

CONFIG_NFS_V4_1 not set;

NFSv4.0 mount passes connectathon tests.

-->Andy

