Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48099 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab3AXPWj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 10:22:39 -0500
Message-ID: <510151BA.3000006@panasas.com>
Date: Thu, 24 Jan 2013 17:22:34 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
CC: amitd <notifications@github.com>
Subject: Re: [nfs-ganesha] Fix FATAL ERROR when FS_specific attribute is missing
 or empty in VFS config (#8)
References: <nfs-ganesha/nfs-ganesha/pull/8@github.com>
In-Reply-To: <nfs-ganesha/nfs-ganesha/pull/8@github.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a fix for this in my tree, for next push

On 01/24/2013 05:08 PM, amitd wrote:
> This happened in Release build due to uninitialized variable ret in fs_specific_has()
> 
> ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------!
 ---
> 
> 
>         You can merge this Pull Request by running
> 
>   git pull https://github.com/amitd/nfs-ganesha fix_fs_specific_has
> 
> Or view, comment on, or merge it at:
> 
>   https://github.com/nfs-ganesha/nfs-ganesha/pull/8
> 
> 
>         Commit Summary
> 
>   * In fs_specific_has(), properly initialize ret
> 
> 
>         File Changes
> 
>   * *M* src/FSAL/FSAL_VFS/export.c (3)
> 
> 
>         Patch Links:
> 
>   * https://github.com/nfs-ganesha/nfs-ganesha/pull/8.patch
>   * https://github.com/nfs-ganesha/nfs-ganesha/pull/8.diff
> 

