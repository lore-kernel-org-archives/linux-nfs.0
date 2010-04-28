From: andros@netapp.com
Subject: [PATCH 0/13] Remove non-file layout code from submit tree
Date: Wed, 28 Apr 2010 18:24:12 -0400
Message-ID: <1272493465-3398-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14209 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932230Ab0D1VYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Applies to 2.6.34-rc3 pnfs-submit branch on top of the "pNFS generic devce ID
cache version 3" patches sent April 26 which includes these patches:
0001-SQUASHME-pnfs_submit-generic-device-ID-cache.patch
0002-SQUASHME-pnfs_submit-fix-multiple-mount-set_pnfs_lay.patch
0003-SQUASHME-pnfs-submit-file-layout-driver-generic-devi.patch

This patch set begins separating non-file layout code from file layout code.

Adjust to using the generic device id cache.
Permanetly remove structure fields and function parameters not used by any
layout driver.
The next patch set will restore object and block layout code removed by these
patches.

0001-SQUASHME-pnfs_submit-remove-GETDEVICELIST.patch
0002-SQUASHME-pnfs_submit-remove-CB_NOTIFY_DEVICEID.patch
0003-SQUASHME-pnfs_submit-remove-pnfs_mount_type-from-all.patch
0004-SQUASHME-pnfs_submit-remove-get_blocksize-policy-ope.patch
0005-SQUASHME-pnfs_submit-remove-ds_wsize-ds_rsize-ds_wpa.patch
0006-SQUASHME-pnfs_submit-remove-uninitialize_mountpoint.patch
0007-SQUASHME-pnfs_submit-remove-struct-pnfs_mount_type.patch
0008-SQUASHME-pnfs_submit-change-initialize_mountpoint-pa.patch
0009-SQUASHME-pnfs_submit-change-nfs_fsino-layoutclass-na.patch
0010-SQUASHME-pnfs_submit-remove-pnfs_fs_ltype.patch
0011-SQUASHME-pnfs_submit-remove-layout_name.patch

File layout code bug fix and cleanup.
0012-SQUASHME-pnfs_submit-fall-back-to-MDS-on-filelayout_.patch
0013-SQUASHME-pnfs_submit-cleanup-nfs4_pnfs_ds_add.patch

Tested:
CONFIG_NFS_V4_1 set

V4.0, V4.1, and pNFS mounts:
Connectathon tests pass.

CONFIG_NFS_V4_1 not set:

Connectathon tests pass.

-->Andy

