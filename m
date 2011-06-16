Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53565 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756968Ab1FPP2j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 11:28:39 -0400
Message-ID: <4DFA211E.5040103@panasas.com>
Date: Thu, 16 Jun 2011 11:28:30 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: =?UTF-8?B?5LqO5rWp?= <haohaoweixiao@hotmail.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: In the linux-all-2.6.38 of pnfs, why was pnfs_return_layout removed
 ?
References: <BLU0-SMTP135422B057EEE4C3CA3C9DEAB6A0@phx.gbl>
In-Reply-To: <BLU0-SMTP135422B057EEE4C3CA3C9DEAB6A0@phx.gbl>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steven, the call was removed to accommodate for the "forgetful client" model
where the client drops its layout unilaterally and the server is supposed
to clean up the client layout on its side.

We are bringing it back, correctly, with proper synchronization, in Linux 3.0
in so that the layout will be returned in nfs_evict_inode.

What server are you testing?
Does the layouts it provides marked with return_on_close?
If so, I pulled a patch from Boaz into pnfs-all-2.6.39 for automatically cleaning up
return_on_close layouts on the server side after a forgetful client closes the file
without returning them.

Benny

On 2011-06-16 10:52, 于浩 wrote:
> 
> Dear All,
> 	Dear All,
> 	I got one problem when testing the read performance of linux-all-2.6.38. I found that the speed was becoming slower with time.(300MB/s-->50MB/s).  Finally,I found the cause of the problem.	In __nfs4_close(), the "LAYOUT RETURN" operation was removed. So the size of  "layout_hash"  becomes bigger and bigger on the pnfs server side. Then more time is spent on searching in __layout_inode_find() function. I wonder why the pnfs_return_layout() in __nfs4_close() was removed ??
> 
> Regards,
>     	Steven.
> 
> ----------------------------------------------------------------------
> SQUASHME: pnfs: revert layout recall/get/return synchronization 
> authorBenny Halevy <bhalevy@panasas.com>
> Thu, 24 Feb 2011 02:53:46 +0000 (18:53 -0800)
> committerBenny Halevy <bhalevy@panasas.com>
> Fri, 25 Mar 2011 08:25:57 +0000 (10:25 +0200)
> 
> For now, revert code attempting a "forget-less" client model to match
> the pnfs-submit-wave4 forgetful model implementation in preparation
> for porting the tree onto it.
> 
> Signed-off-by: Benny Halevy bhalevy@panasas.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
