From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/13] Remove non-file layout code from submit tree version
 2
Date: Thu, 06 May 2010 22:48:05 +0300
Message-ID: <4BE31CF5.4000901@panasas.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60599 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757122Ab0EFTsO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:48:14 -0400
Received: by wyg36 with SMTP id 36so287733wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 12:48:13 -0700 (PDT)
In-Reply-To: <1272573291-8986-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 29, 2010, 23:34 +0300, andros@netapp.com wrote:
> Applies to 2.6.34-rc5 pnfs-submit branch on top of the "pNFS generic devce ID
> cache version 3" patches sent April 26 which includes these patches:
> 0001-SQUASHME-pnfs_submit-generic-device-ID-cache.patch
> 0002-SQUASHME-pnfs_submit-fix-multiple-mount-set_pnfs_lay.patch
> 0003-SQUASHME-pnfs-submit-file-layout-driver-generic-devi.patch
> 
> This patch set begins separating non-file layout code from file layout code.
> 
> Responded to version 1 comments and kept uninitialize_mountpoint.
> Adjust to using the generic device id cache.
> Permanetly remove structure fields and function parameters not used by any
> layout driver.
> The next patch set will restore object and block layout code removed by these
> patches.
> 
> 0001-SQUASHME-pnfs_submit-remove-GETDEVICELIST.patch
> 0002-SQUASHME-pnfs_submit-remove-CB_NOTIFY_DEVICEID.patch
> 0003-SQUASHME-pnfs_submit-remove-pnfs_mount_type-from-all.patch
> 0004-SQUASHME-pnfs_submit-remove-get_blocksize-policy-ope.patch
> 0005-SQUASHME-pnfs_submit-remove-ds_wsize-ds_rsize-ds_wpa.patch
> 0006-SQUASHME-pnfs_submit-update-uninitialize_mountpoint.patch
> 0007-SQUASHME-pnfs_submit-remove-struct-pnfs_mount_type.patch
> 0008-SQUASHME-pnfs_submit-change-initialize_mountpoint-pa.patch
> 0009-SQUASHME-pnfs_submit-change-nfs_fsino-layoutclass-na.patch
> 0010-SQUASHME-pnfs_submit-remove-pnfs_fs_ltype.patch
> 0011-SQUASHME-pnfs_submit-remove-layout_name.patch
> 
> File layout code bug fix and cleanup.
> 0012-SQUASHME-pnfs_submit-fall-back-to-MDS-on-filelayout_.patch
> 0013-SQUASHME-pnfs_submit-cleanup-nfs4_pnfs_ds_add.patch

All committed to pnfs-submit. Thanks!

Benny

> 
> Tested:
> CONFIG_NFS_V4_1 set
> 
> V4.0, V4.1, and pNFS mounts:
> Connectathon tests pass.
> 
> CONFIG_NFS_V4_1 not set:
> 
> Connectathon tests pass.
> 
> -->Andy
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

