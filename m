Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26788 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752710Ab0I2K7M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 06:59:12 -0400
Message-ID: <4CA31BFE.7080101@panasas.com>
Date: Wed, 29 Sep 2010 12:59:10 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/12] RFC: pnfs: LAYOUTGRT/DEVINFO submission, v3
References: <1285193110-24073-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285193110-24073-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks!

I've released pnfs-all-2.6.36-rc6-2010-09-29 based on this patchset
and your rebase of pnfs-submit in bennys-pnfs-submit-on-devinfo-rc5.

I've made a few fixes on top of it and rebased everything else
on top of it (which was quite painful :)

I'll send the list of patches separately.

Benny

On 2010-09-23 00:04, Fred Isaman wrote:
> This fixes various issue brought up in comments to the previous version.
> 
> Major changes are:
> bugfixes and renames in the deviceid cache
> fix Kconfig using a suggestion from Trond
> moved module_get to simplify and avoid bug in find_pnfs_driver_locked
> 
> For those interested, the patches can also be found at
> git://linux-nfs.org/~iisaman/linux-pnfs.git,
> under the branch devinfo-submit-rc5-trond
> 
> A rebase of Benny's pnfs-submit branch onto these patches is under
> the branch bennys-pnfs-submit-on-devinfo-rc5
> 
> 
> 
> 
> 
> This is the start of code implementing pnfs, based on RFC 5661.  Since
> sending the whole thing at once would be overwhelming, we are trying
> to break it into bite sized chunks.  This chunk implements the
> mount/umount infrastructure, as well as sending the LAYOUTGET and
> GETDEVTICEINFO calls on io (but not actually using the information for
> io).  Note that two major simplifications to the protocol will be made 
> throughout the initial submission process:  only the file layout
> driver is considered, and only whole file layouts are requested.
> 
> 
> These patches apply against Trond's nfs-for-2.6.37 branch.
> 
> patches 01-08 implement the mount/umount hooks
> patches 09-12 implement LAYOUTGET and GETDEVICEINFO
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
