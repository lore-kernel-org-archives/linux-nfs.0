Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36249 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065Ab0DLMMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Apr 2010 08:12:20 -0400
Date: Mon, 12 Apr 2010 08:12:18 -0400
To: andros@netapp.com
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: Re: [pnfs] [PATCH 0/14] pnfs_submit file layout client device
	management
Message-ID: <20100412121218.GB16171@fieldses.org>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1270756450-5570-1-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 08, 2010 at 03:53:56PM -0400, andros@netapp.com wrote:
> 
> Apply against 2.6.34-rc3 pnfs branch. For pNFS client submission. Only touches
> the file layout driver.
> 
> This set of patches implements several design changes enmerated at
> http://wiki.linux-nfs.org/wiki/index.php/Porposed_Device_ Manangement_Design.

(Should be:

http://wiki.linux-nfs.org/wiki/index.php/Proposed_Device_Management_Design

.)

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
