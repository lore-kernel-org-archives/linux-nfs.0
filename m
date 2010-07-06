Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35244 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752052Ab0GFNve (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 09:51:34 -0400
Message-ID: <4C3334E3.7070600@panasas.com>
Date: Tue, 06 Jul 2010 16:51:31 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, Andy Adamson <andros@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 0/6] Some pnfs-submit love
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Some cleanup love to pnfs code.

Andy this would conflict with your dropped:
	[PATCH 03/10] SQUASHME pnfs-submit: clear page lseg on partial i/o

I redone them based on Current Benny's tree.

[PATCH 1/6] SQUASME pnfs-submit: Collapse pnfs_try_to_write_data code path and avoid big fat inlines
[PATCH 2/6] SQUASME pnfs-submit: Collapse pnfs_try_to_read_data code path and avoid big fat inlines
[PATCH 3/6] SQUASME pnfs-submit: Collapse pnfs_try_to_commit code path and avoid big fat inlines
[PATCH 4/6] SQUASHME: pnfs-submit: Move _pnfs_clear_lseg_from_pages to pnfs.c
[PATCH 5/6] SQUASHME: pnfs-commit: Fix scariness in nfs4_clear_inode
[PATCH 6/6] SQUASHME: pnfs-submit: pnfs_return_layout remove surrounding #ifdef CONFIG_NFS_V4_1

Please review?
Boaz

