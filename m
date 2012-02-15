Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:45140 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752487Ab2BORJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 12:09:05 -0500
Message-ID: <4F3BE6B0.2090200@opengridcomputing.com>
Date: Wed, 15 Feb 2012 11:09:04 -0600
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Al Viro <viro@ZenIV.linux.org.uk>, Tom Tucker <tom@ogc.us>,
        trond.myklebust@netapp.com, dan.carpenter@oracle.com,
        linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] svcrdma: Cleanup sparse warnings in the svcrdma module
References: <1329260485-16994-1-git-send-email-tom@ogc.us> <20120214232342.GB23916@ZenIV.linux.org.uk> <20120215161625.GC12490@fieldses.org>
In-Reply-To: <20120215161625.GC12490@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/15/12 10:16 AM, J. Bruce Fields wrote:
> OK, Tom could you fix up these small things and repost?

Sure, but just to be certain I understand fully,

> --b.
>
> On Tue, Feb 14, 2012 at 11:23:42PM +0000, Al Viro wrote:
>> On Tue, Feb 14, 2012 at 05:01:25PM -0600, Tom Tucker wrote:
>>
>>> -	if (ch->rc_discrim == 0)
>>> +	if (ch->rc_discrim == xdr_zero)

You don't want this? It is true that sparse didn't complain, I was simply 
making it obvious that this value is NBO and be consistent across the 
code. Other places were using xdr_zero.

>> Mostly, ACK, modulo this and similar sillyness.  sparse is just fine with
>> use of constant 0 in bitwise contexts; it's also just fine with use of
>> bitwise in logical ones.
>>
>>> +	nchunks = ntohl(ary->wc_nchunks);
>>>   	if (((unsigned long)&ary->wc_array[0] +
>>> -	     (sizeof(struct rpcrdma_write_chunk) * ary->wc_nchunks))>
>>> +	     (sizeof(struct rpcrdma_write_chunk) * nchunks))>
>> BTW, this still can overflow.  With less painful consequences than before that
>> patch, but...
>>
>>> -			BUG_ON(0 == virt_to_page(vec[i].iov_base));
>>> +			BUG_ON(NULL == virt_to_page(vec[i].iov_base));
>> Egads...  What, "!virt_to_page(...)" would have been too pedestrian?

