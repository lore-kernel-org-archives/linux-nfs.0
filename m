Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37147 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495Ab1EZTDO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:03:14 -0400
Message-ID: <4DDEA3F3.4030308@panasas.com>
Date: Thu, 26 May 2011 22:03:15 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 31/32] NFSv4.1: define nfs_generic_pg_test
References: <4DDD7392.6040505@panasas.com> <1306359021-17987-1-git-send-email-bhalevy@panasas.com> <4DDE612D.3050807@panasas.com> <4DDE99E6.8050508@panasas.com>
In-Reply-To: <4DDE99E6.8050508@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 09:20 PM, Benny Halevy wrote:
> On 2011-05-26 17:18, Boaz Harrosh wrote:
>>> @@ -294,8 +293,6 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>>>  		if (desc->pg_bsize < PAGE_SIZE)
>>>  			return 0;
>>
>> What about this part? what is desc->pg_bsize? Is it not what was negotiated with the
>> MDS? this too should be ignored in PNFS. Maybe just add it to the generic test? me think
> 
> Agreed.
> 
> Benny
> 

>>
>> Boaz

I have a patch for this I'm just now sending it in with all the rest of them

Boaz
