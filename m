Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:59609 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453Ab1H2XfA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 19:35:00 -0400
Message-ID: <4E5C21E2.4070903@panasas.com>
Date: Mon, 29 Aug 2011 16:33:54 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: David Miller <davem@davemloft.net>, <joe@perches.com>,
        <bfields@fieldses.org>, <neilb@suse.de>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
References: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com><20110829.143751.1153162956919885670.davem@davemloft.net><4E5C0AB3.90401@panasas.com> <20110829.180348.1774953636752413432.davem@davemloft.net> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/29/2011 04:25 PM, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
<>
>> They've been doing this for years, so obviously they haven't bothered
>> you enough to care up to this point.
>>
>> All of this pushback is pure uneducated noise, please stop blocking
>> progress with poorly informed objections.
> 
> I can see that slub.c has the slab_out_of_memory() function that
> (although ratelimited) warns you if the allocation failed. However I
> can't find any equivalent for slab.c or slob.c.
> 

OK That would explain why I never saw it in my debugging. For some reason
I'm always using slab. 

Which one is the best for development and memory problems debugging?

> Trond

Thanks
Boaz
