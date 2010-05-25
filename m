Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45567 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932996Ab0EYUOB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 16:14:01 -0400
Received: by pwi2 with SMTP id 2so1225577pwi.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 13:14:01 -0700 (PDT)
Message-ID: <4BFC2FA2.2050506@gmail.com>
Date: Tue, 25 May 2010 13:14:26 -0700
From: Dean Hildebrand <seattleplus@gmail.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/22] LAYOUTGET invocation
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com> <4BFC1686.4000509@gmail.com> <51AD8F7D-D172-4DE6-8F7A-CDFA292CBF8B@netapp.com>
In-Reply-To: <51AD8F7D-D172-4DE6-8F7A-CDFA292CBF8B@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Fred Isaman wrote:
> On May 25, 2010, at 2:27 PM, Dean Hildebrand wrote:
>
>   
>> Fred Isaman wrote:
>>     
>>> (My apologies for the 4 patches that went out about 1/2 hour ago.  Please ignore those.)
>>>
>>> This patch series limits LAYOUTGET invocation to the beginning of the IO paths.
>>>
>>> It is intended for the pnfs_submit branch, without reversion in a post_submit branch.
>>>
>>> Patches 1-4 revert direct IO.  Commit is already broken, and this series breaks them further.  The problem is that the direct IO redefines data->wb_req and data->pages, so that it can only work with the pnfs code if we don't look at those fields.
>>>  
>>>       
>> Can you give some history on this?  Is it crashing?  Has this problem been around for a long time or is a new set of patches causing the problem?  Does this affect pNFS O_DIRECT or all O_DIRECT code?
>>
>>     
>
> Any use of pnfs_commit from the directIO code will cause a crash.
>
> In my current tree, the breakage is introduced by with pnfs_commit in patch 3ca1c1136, (use of variables first and last), but because of all the rewriting I can't tell how long it has been around, though I suspect since the beginning given the reliance in filelayout_commit (patch a43d8107) on wb_pages.  If the directIO avoided commit, then it is not obviously broken.
>
>
>   
>> I don't think revert is the right way to go about this.  Removing support for O_DIRECT because changes to the non-O_DIRECT path break it would not fly in the mainline, and so I don't see why it would fly here.  At the minimum, since O_DIRECT is a B-list feature, I could see it being commented/ifdef'd out for the time being, but completely removing the patches is extremely invasive considering this is a b-list development branch.
>>
>>     
>
> The problem is the redefinition of the data->wb_req and wb_pages fields.  For directIO to work, these either have to be marked as completely off limits to the pnfs code and the filelayout commit code in particular rewritten, or the directIO (not just the pnfs directIO) needs to be substantially rewritten. 
>
> I can send some post_submit patches with the code ifdef'ed out if people would be content with that.
>   

Thanks for the background.  I would be much happier if you sent patches 
with the code ifdef'd out, added with the comment in the code regarding 
which patches you believe introduced the problem.

Dean
> Fred
>
>
>   
>> Dean
>>
>>     
>>> Patches 5-8 do some code cleanup in preperation for the real work.
>>>
>>> Patches 9-19 implement the change.  NOTE that patch 19 changes the calling convention of the layout drivers commit calls.  There is no longer a universal lseg for the commit, instead each nfs_page has an lseg attached, with NULL meaning to go through the MDS.
>>>
>>> Patches 20-22 rework the filelayout commit function, and then do some code cleanup this enables.
>>>
>>>
>>>
>>> The basic idea of these patches is as follows:
>>>
>>> We attempt to grab a lseg (possibly invoking LAYOUTGET) early in the IO.  If we succeed, we refcount and stash it, using it through the rest of the io.  If we fail, we revert to straight nfs, even if the area becomes covered by a layout due to other io.
>>>
>>> The tricky, though hopefully anomalous, case is when we start without the layout, but have it at this particular stage of the IO.  We ignore this for the moment at write_pages, which will cause block and object to issue CB_LAYOUTRECALL.  At commit, it is tricky to handle, but since block doesn't use commit, and file needs to handle complicated splitting anyway, I just push all complicated decisions of splitting commit between nfs (for IO started without layout) and pnfs to the driver.
>>>
>>> Fred
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>  
>>>       
>
>   
