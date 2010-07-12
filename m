Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:65374 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753613Ab0GLSi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:38:28 -0400
Message-ID: <4C3B611C.1000208@panasas.com>
Date: Mon, 12 Jul 2010 21:38:20 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] layout rework fixes
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following fixes result from Andy latest patchset to change
nfs_inode.layout into a pointer and reworking the layout allocation scheme.

[PATCH 1/2] SQUASHME: pnfs-submit: check has_layout in __nfs4_close
This fixes a NULL dereference on __nfs4_closer when the layout is NULL.

[PATCH 2/2] SQUASHME: pnfs-submit: clean up nfs_lock_alloc_layout
This fixes a BUG_ON where nfs_lock_alloc_layout did not lock the inode
if the layout was already allocated.
