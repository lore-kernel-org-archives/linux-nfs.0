Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:53760 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932566Ab0EYS0y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 14:26:54 -0400
Received: by pxi18 with SMTP id 18so2094344pxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 11:26:53 -0700 (PDT)
Message-ID: <4BFC1686.4000509@gmail.com>
Date: Tue, 25 May 2010 11:27:18 -0700
From: Dean Hildebrand <seattleplus@gmail.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/22] LAYOUTGET invocation
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Fred Isaman wrote:
> (My apologies for the 4 patches that went out about 1/2 hour ago.  Please ignore those.)
>
> This patch series limits LAYOUTGET invocation to the beginning of the IO paths.
>
> It is intended for the pnfs_submit branch, without reversion in a post_submit branch.
>
> Patches 1-4 revert direct IO.  Commit is already broken, and this series breaks them further.  The problem is that the direct IO redefines data->wb_req and data->pages, so that it can only work with the pnfs code if we don't look at those fields.
>   

Can you give some history on this?  Is it crashing?  Has this problem 
been around for a long time or is a new set of patches causing the 
problem?  Does this affect pNFS O_DIRECT or all O_DIRECT code?

I don't think revert is the right way to go about this.  Removing 
support for O_DIRECT because changes to the non-O_DIRECT path break it 
would not fly in the mainline, and so I don't see why it would fly 
here.  At the minimum, since O_DIRECT is a B-list feature, I could see 
it being commented/ifdef'd out for the time being, but completely 
removing the patches is extremely invasive considering this is a b-list 
development branch.

Dean

> Patches 5-8 do some code cleanup in preperation for the real work.
>
> Patches 9-19 implement the change.  NOTE that patch 19 changes the calling convention of the layout drivers commit calls.  There is no longer a universal lseg for the commit, instead each nfs_page has an lseg attached, with NULL meaning to go through the MDS.
>
> Patches 20-22 rework the filelayout commit function, and then do some code cleanup this enables.
>
>
>
> The basic idea of these patches is as follows:
>
> We attempt to grab a lseg (possibly invoking LAYOUTGET) early in the IO.  If we succeed, we refcount and stash it, using it through the rest of the io.  If we fail, we revert to straight nfs, even if the area becomes covered by a layout due to other io.
>
> The tricky, though hopefully anomalous, case is when we start without the layout, but have it at this particular stage of the IO.  We ignore this for the moment at write_pages, which will cause block and object to issue CB_LAYOUTRECALL.  At commit, it is tricky to handle, but since block doesn't use commit, and file needs to handle complicated splitting anyway, I just push all complicated decisions of splitting commit between nfs (for IO started without layout) and pnfs to the driver.
>
> Fred
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
