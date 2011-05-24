Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50526 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661Ab1EXQEs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 12:04:48 -0400
Message-ID: <4DDBD704.5020303@panasas.com>
Date: Tue, 24 May 2011 19:04:20 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SQUASHME: objio read/write patch: Bugs fixes
References: <4DDA8C3D.5080706@panasas.com> <1306168626-11463-1-git-send-email-bhalevy@panasas.com> <4DDAB94C.6070407@panasas.com> <4DDBAE2B.2060705@panasas.com> <4DDBC2B4.9040305@panasas.com> <4DDBD551.8010603@panasas.com>
In-Reply-To: <4DDBD551.8010603@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/24/2011 06:57 PM, Benny Halevy wrote:
> On 2011-05-24 17:37, Boaz Harrosh wrote:
>> On 05/24/2011 04:10 PM, Benny Halevy wrote:
>>>
>>> This hunk doesn't apply cleanly, as in the latest version
>>> we pass gfp_flags, not GFP_KERNEL.
>>>
>>>>  	if (!objio_seg)
>>>>  		return -ENOMEM;
>>>>  
>>
>> Please don't do anything. I'm just now sending a clean
>> SQUASHME set
>>
>> Please talk to me
>>
>> Boaz]
> 
> OK. I'm waiting for a plumber to arrive in a few minutes
> so I'll call you later today...
> 
> Benny
> 

Thanks Benny.

I've now re-sent all the fixes in the right order and properly
separated, to be able to cleanly squash on the V6 patchset from you.
Please see my mail:
   [PATCHES 00/12] Mostly a Resend of ALL Bug fixes and SQUASHMEs - pnfs-submit 2.6.40 V7
and the thread that follows, also the proposed patch reorder.

Tell me if you also need the cleaned squashed set. It is no problem.

Boaz
