Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f52.google.com ([209.85.212.52]:60359 "EHLO
	mail-vw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab1IUPpu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 11:45:50 -0400
Received: by vws10 with SMTP id 10so2725310vws.11
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 08:45:50 -0700 (PDT)
In-Reply-To: <4E79ED02.5010104@panasas.com>
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
 <1316488728-24912-3-git-send-email-rees@umich.edu> <1316558461.15093.4.camel@lade.trondhjem.org>
 <20110921002917.GA30770@merit.edu> <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com>
 <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com>
 <4E798C93.40409@tonian.com> <F19688880B763E40B28B2B462677FBF805C4952A24@MX09A.corp.emc.com>
 <4E79C2F0.30303@tonian.com> <F19688880B763E40B28B2B462677FBF805C4952A34@MX09A.corp.emc.com>
 <4E79CA34.3060602@tonian.com> <4E79CD8F.6050901@panasas.com>
 <4E79CFA3.4090403@tonian.com> <4E79ED02.5010104@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 21 Sep 2011 23:45:30 +0800
Message-ID: <CA+a=Yy7PNsrQQdc9nwn1+2bZu86s8xUa9NBXVeo7NecGkc9-VQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>, tao.peng@emc.com,
        Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        honey@citi.umich.edu, rees@umich.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 21, 2011 at 9:56 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 09/21/2011 02:50 PM, Benny Halevy wrote:
>> On 2011-09-21 14:42, Boaz Harrosh wrote:
>>> On 09/21/2011 02:27 PM, Benny Halevy wrote:
>>>>> Unless we do following:
>>>>> 1. preallocate memory for extent state convertion
>>>>> 2. use nfsiod/rpciod to handle bl_write_cleanup
>>>>> 3. for pnfs error case, create a kthread to recollapse and resend to MDS
>>>>> I don't quite understand. How do you use nfs state manager to do other tasks?
>>>>
>>>> You need to keep a list of things to do hanging off of the nfs client structure
>>>> and set a bit in cl_state telling the state manager it has work to do
>>>> and wake it up.  It then needs to go over the list of, say nfs_inodes
>>>> and call into the layout driver to handle the errors.
>>>>
>>>> Benny
>>>
>>> Good god, Is it not already too complicated?
>>>
>>> The LD is out of the picture. You all seemed to agree that
>>> the LD has reported an io_done on the nfsiod/rpciod, and in the error case
>>> Generic layer needs to do it's coalescing on some other thread. So
>>> your description above is not correct, the LD is out of the picture.
>>>
>>
>> True, if the ld cleanup on io_done is sufficient.
>>
>>> It all looks too complicated for me. A pnfs workqueue for both 2 and 3
>>> above is very good. Specially since the workqueue also shares global
>>> pool threads, No? I like it that there is a preallocated thread for
>>> the error-case, think about it.
>>
>> I'm fine too with using a workqueue for the error case.
>> But I'd rather have the common case done path do only lightweight,
>> wait free processing.
>>
>> Benny
>>
>
> If by "common case done path do only lightweight" you mean
> "preallocate memory for extent state conversion". Then I absolutely
> agree. But as far as workqueue/kthread then nfsiod/rpciod-wq or
> pnfs-wq is exactly the same for the "common case". Unless I'm
> totally missing the point. What are you saying?
>
> These are the options so far:
>
> [Toe's option which he rather not]
> 1. preallocate memory for extent state conversion
> 2. use nfsiod/rpciod to handle bl_write_cleanup
> 3. for pnfs error case, create a kthread to recollapse and resend to MDS
>
> [My option which I think Toe agrees with]
> 1. preallocate memory for extent state conversion
> 2. use pnfs-wq to handle bl_write_cleanup
> 3. pnfs error case, just like Toe's patches as part of io_done
>   on pnfs-wq
Yeah, I would vote for this one because of its simplicity. ;-)

Thanks,
Tao
>
> Any other options?
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Thanks,
-Bergwolf
