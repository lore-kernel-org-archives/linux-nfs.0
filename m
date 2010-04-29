From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 06/13] SQUASHME pnfs_submit: remove uninitialize_mountpoint
Date: Thu, 29 Apr 2010 20:03:35 +0300
Message-ID: <4BD9BBE7.6060206@panasas.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com> <1272493465-3398-2-git-send-email-andros@netapp.com> <1272493465-3398-3-git-send-email-andros@netapp.com> <1272493465-3398-4-git-send-email-andros@netapp.com> <1272493465-3398-5-git-send-email-andros@netapp.com> <1272493465-3398-6-git-send-email-andros@netapp.com> <1272493465-3398-7-git-send-email-andros@netapp.com> <4BD9B35B.702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39365 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759058Ab0D3S1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Apr 2010 14:27:15 -0400
Received: by wye20 with SMTP id 20so400595wye.19
        for <linux-nfs@vger.kernel.org>; Fri, 30 Apr 2010 11:27:14 -0700 (PDT)
In-Reply-To: <4BD9B35B.702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/29/2010 07:27 PM, Boaz Harrosh wrote:
> On 04/29/2010 01:24 AM, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> The layoutdriver_io_operations uninitialize_mountpoint function is used
>> to free a layout driver specific device id cache.
>> The device id cache is now shared and moved to struct nfs_client and can be
>> removed in the generic unmount_pnfs_layoutdriver routine.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
> 
> What ? no.
> 
> uninitialize_mountpoint is where the mountid private data is deallocated.
> The one that was allocated at initialize_mountpoint.
> 
> Files layout might not currently have any, but we do and it will has well.
> Any way what kind of API has initialize call and not an uninitialize call
> Even if it's empty
> 
> NACK
> 

You are right that currently it's only device cache things. But I have code in
Q that have a page pool cache for RAID5/6 IO, and other initialization I need.

Please keep the initialize and a symmetric uninitialize and keep some private
data for each sb. It does not cost any thing. You could get rid of the double
indirection though.

Thanks
Boaz
