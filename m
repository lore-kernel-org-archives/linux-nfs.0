From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 0/14] pnfs_submit file layout client device management
Date: Mon, 12 Apr 2010 22:03:21 +0300
Message-ID: <4BC36E79.5000500@panasas.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18674 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752862Ab0DLTDY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2010 15:03:24 -0400
In-Reply-To: <1270756450-5570-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Committed to a new branch in the 2.6.34-rc3 stream: pnfs-submit

Thanks!

Benny

On Apr. 08, 2010, 22:53 +0300, andros@netapp.com wrote:
> 
> Apply against 2.6.34-rc3 pnfs branch. For pNFS client submission. Only touches
> the file layout driver.
> 
> This set of patches implements several design changes enmerated at
> http://wiki.linux-nfs.org/wiki/index.php/Porposed_Device_ Manangement_Design.
> 
> - Only call GETDEVICEINFO from one place
> - Only cache the first data server in the multipath_list4 array.
> - Wait to connect to data server when needed for I/O
> - Move data server cache to stand alone cache
> 
> Also some cleanup, and function interfaces are changed in 
> preparation for the soon to come generic deviceid cache.
> 
> 0001-SQUASHME-pnfs_submit-remove-unused-getdevicelist-fun.patch
> 0002-SQUASHME-pnfs-submit-call-get_device_info-from-filel.patch
> 0003-SQUASHME-pnfs_submit-remove-multilist4-caching.patch
> 0004-SQUASHME-pnfs_submit-wait-for-I-O-for-data-server-co.patch
> 0005-SQUASHME-pnfs_submit-remove-xdr-macros.patch
> 0006-SQUASHME-pnfs_submit-remove-unused-nfs4_pnfs_device_.patch
> 0007-SQUASHME-pnfs_submit-change-get_device_info-paramete.patch
> 0008-SQUASHME-pnfs_submit-change-decode_and_add_device-pa.patch
> 0009-SQUASHME-pnfs_submit-change-decode_device-parameter.patch
> 0010-SQUASHME-pnfs_submit-change-decode_and_add_ds-parame.patch
> 0011-SQUASHME-pnfs_submit-change-nfs4_pnfs_ds_add-paramet.patch
> 0012-SQUASHME-pnfs_submit-remove-filelayout-CB_NOTIFY_DEV.patch
> 0013-SQUASHME-pnfs_submit-stand-alone-data-server-cache.patch
> 0014-SQUASHME-pnfs_submit-remove-kfree-from-under-spinloc.patch
> 
> Testing:
> CONFIG_NFS_V4_1 set:
> pNFS mount, NFSv4.1 mount, NFSv4.0 mount:
> Connecatathon tests pass. pyNFS testclient tests pass.
> 
> CONFIG_NFS_V4_1 not set:
> Connecatahon tests pass.
> 
> 
> -->Andy
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
