Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47493 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab1BUWqs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:46:48 -0500
Message-ID: <4D62EB58.7000600@panasas.com>
Date: Mon, 21 Feb 2011 14:46:48 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: linux-pnfs-cthon git tree
References: <4D62EA13.1000809@panasas.com>
In-Reply-To: <4D62EA13.1000809@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-21 14:41, Benny Halevy wrote:
> I've set up a git tree for Connectathon to hold up the fixes we're testing
> here temporarily.  I'll update the main tree when we're done so not to cause
> unnecessary churn.

Oops, here's the tree's url:

git://linux-nfs.org/~bhalevy/linux-pnfs-cthon.git

or

ssh://linux-nfs.org/~bhalevy/exports/linux-pnfs-cthon.git
if you don't have git access (and have ssh access to linux-nfs.org).

If you need local access on the cthon network
the latest tree is also available on
git://10.41.21.1/linux-pnfs.git

However, as it's stored on my laptop it might be unavailable
intermittently.  Please coordinate with me when you're pulling it
to make sure it stays up.

Bennny 

> 
> The following branches have been posted up:
> 
>   pnfs-all-2.6.37
>   pnfs-all-latest 	# based on v2.6.38-rc5
>   pnfs-submit-wave3	# based on v2.6.38-rc5 .. Andy's wave3-rev11 .. Fred's 2 SQUASHMEs
>   pnfs-submit-wave4	# based on pnfs-submit-wave3 and Fred's wave4 patches
> 
> The -all branches include the fixes for layout recall that I've posted on the mailing list.
> 
> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
