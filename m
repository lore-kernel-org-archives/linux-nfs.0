From: andros@netapp.com
Subject: [PATCH 0/5] pnfs-submit fix kfree under spin lock
Date: Tue, 20 Jul 2010 13:01:18 -0400
Message-ID: <1279645283-9862-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758478Ab0GTRBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 13:01:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fix kfree under spin lock

Both put_lseg and put_layout are called under the inode i_lock where the
last reference will end up freeing structures.

I know there has been a lot of churn in this code, but free'ing under the
spin lock is a no-no.
In this patch I refactor the layout allocation, combining it with the
layout segment lookup code. The new function, pnfs_get_layout_segment takes
inode spin lock, and looks to see if the requested range is serviced by an
existing layout segment. If the layout has not been allocated, allocate it.
If a layout segement is found, reference it and give up the lock. If no
layout segment is found, reference the layout for the layoutget call and 
give up the lock.

0001-SQUASHME-pnfs-submit-alloc-layout-don-t-call-put_lay.patch
0002-SQUASHME-pnfs-submit-use-atomic_dec_and_lock-for-lay.patch

Fix the put_lseg under spin lock.
0003-SQUASHME-pnfs-submit-don-t-call-put_lseg-under-spin-.patch

Cleanup.
0004-SQUASHME-pnfs-submit-pnfs_release_layout-just-use-in.patch
0005-SQUASHME-pnfs-submit-fix-has_layout-compile-error.patch

Tests:
CONFIG_NFS_V4_1 set:
Connectathon tests pass against GFS2 and pyNFS file layout servers.

CONFIG_NFS_V4_1 not set:
Connectathon tests pass.

-->Andy

