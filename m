Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933859Ab0D3S1m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 14:27:42 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Restore non-file layout code version 2 
Date: Fri, 30 Apr 2010 14:27:07 -0400
Message-Id: <1272652032-2496-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0



Applies to 2.6.34-rc5 pnfs-submit branch on top of the "pNFS generic devce ID
cache version 3" and " Remove non-file layout code from submit tree version 2"

This patch set restores object and block functionality removed in the
pnfs-submit tree.

Adjust to using the generic device id cache.
Permanetly remove structure fields and function parameters not used by any
layout driver.

Note: struct nfs_server pnfs_mount_type pointer was removed as it was unused
due to the generic deviceid cache. The file layout driver does not need a
private data pointer in struct nfs_server, and currently, neither does the
object nor block layout driver. Once code is submitted that needs a private
data pointer, (as I'm told is on the way) we can add one.

Note: The CB_NOTIFY_DEVICEID code is incomplete in that all layout segments
referring to the 'to be removed device id' need to be reaped, and all in-flight
I/O drained prior to device id removal.
Note: The generic device id cache means that there is no longer any need for
a per layout driver delete_deviceid call.
0001-pnfs_post_submit-restore-CB_NOTIFY_DEVICEID.patch

For the block layout driver: Please review and test.
Note: new getdevicelist layoutdriver_io_operation.
0002-pnfs_post_submit-restore-GETDEVICELIST.patch
0003-pnfs_post_submit-add-getdevicelist-io-operation.patch

For the object layout driver. Please review and test.
Note: Just removed the unused ds_wpages and ds_rpages.
0004-pnfs_post_submit-restore-ds_wsize-and-ds_rsize.patch
0005-pnfs_post_submit-restore-get_blocksize-policy-operat.patch


Testing:
-------

The file layout driver does not use this code, so I could not test, and the
code has changed due to the generic device id cache.

I did run Connectathon to smoke test that the file layout functionality has not
changed.


-->Andy

