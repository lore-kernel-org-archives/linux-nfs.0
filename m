Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50088 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932363Ab1EXP5J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:57:09 -0400
Message-ID: <4DDBD551.8010603@panasas.com>
Date: Tue, 24 May 2011 18:57:05 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SQUASHME: objio read/write patch: Bugs fixes
References: <4DDA8C3D.5080706@panasas.com> <1306168626-11463-1-git-send-email-bhalevy@panasas.com> <4DDAB94C.6070407@panasas.com> <4DDBAE2B.2060705@panasas.com> <4DDBC2B4.9040305@panasas.com>
In-Reply-To: <4DDBC2B4.9040305@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-24 17:37, Boaz Harrosh wrote:
> On 05/24/2011 04:10 PM, Benny Halevy wrote:
>>
>> This hunk doesn't apply cleanly, as in the latest version
>> we pass gfp_flags, not GFP_KERNEL.
>>
>>>  	if (!objio_seg)
>>>  		return -ENOMEM;
>>>  
> 
> Please don't do anything. I'm just now sending a clean
> SQUASHME set
> 
> Please talk to me
> 
> Boaz]

OK. I'm waiting for a plumber to arrive in a few minutes
so I'll call you later today...

Benny

