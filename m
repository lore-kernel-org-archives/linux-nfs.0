From: Benny Halevy <benny@tonian.com>
Subject: Re: Bad extra hunk at pan_layout driver pathes
Date: Fri, 12 Aug 2011 10:54:48 +0300
Message-ID: <4E44DC48.3080700@tonian.com>
References: <4E445726.1000702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <benny@tonian.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40689 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab1HLHyx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 03:54:53 -0400
Received: by fxh19 with SMTP id 19so2156846fxh.19
        for <linux-nfs@vger.kernel.org>; Fri, 12 Aug 2011 00:54:52 -0700 (PDT)
In-Reply-To: <4E445726.1000702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-08-12 01:26, Boaz Harrosh wrote:
> Hi Benny
> 
> In your pNFS git tree at patch:
> 	99432a3 pnfs-obj: panlayout: panfs_shim objects IO engine
> 
> There is an extra hunk at Kconfig re-adding the PNFS_BLOCKS See below
> 
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index be02077..4f42384 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -104,6 +104,24 @@ config PNFS_OBJLAYOUT
>>  
>>  	  If unsure, say N.
>>  
>> +config PNFS_PANLAYOUT
>> +	tristate "Provide support for the Panasas OSD Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
>> +	depends on PNFS_OBJLAYOUT
>> +	help
>> +	  Say M or y here if you want your pNFS client to support the Panasas OSD Layout Driver.
>> +
>> +	  If unsure, say N.
>> +
> 
> vvvvv Below is not needed
> 
>> +config PNFS_BLOCK
>> +	tristate "Provide a pNFS block client (EXPERIMENTAL)"
>> +	depends on NFS_FS && NFS_V4_1
>> +	select MD
>> +	select BLK_DEV_DM
>> +	help
>> +	  Say M or y here if you want your pNfs client to support the block protocol
>> +
>> +	  If unsure, say N.
>> +
> 
> Please remove it below is a reverting diff
> 
> Thanks
>>  config ROOT_NFS
>>  	bool "Root file system on NFS"
>>  	depends on NFS_FS=y && IP_PNP
> 
> ---
> From 5f183d5217b7714c848913f939c6d79b725e652b Mon Sep 17 00:00:00 2001
> From: Boaz Harrosh <bharrosh@panasas.com>
> Date: Thu, 11 Aug 2011 15:23:06 -0700
> Subject: [PATCH] SQUASHME: pnfs-obj: panlayout: Remove a miss-merge in Kconfig
> 
> Looks like a rebase fallout
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/Kconfig |   10 ----------
>  1 files changed, 0 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index ad5aed0..26448dc 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -106,16 +106,6 @@ config PNFS_PANLAYOUT
>  
>  	  If unsure, say N.
>  
> -config PNFS_BLOCK
> -	tristate "Provide a pNFS block client (EXPERIMENTAL)"
> -	depends on NFS_FS && NFS_V4_1
> -	select MD
> -	select BLK_DEV_DM
> -	help
> -	  Say M or y here if you want your pNfs client to support the block protocol
> -
> -	  If unsure, say N.
> -
>  config ROOT_NFS
>  	bool "Root file system on NFS"
>  	depends on NFS_FS=y && IP_PNP

Grr, sorry about that.
Fixed.  Thanks for spotting!

Benny
