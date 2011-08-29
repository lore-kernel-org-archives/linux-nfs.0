Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:58255 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992Ab1H2WCS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 18:02:18 -0400
Message-ID: <4E5C0AB3.90401@panasas.com>
Date: Mon, 29 Aug 2011 14:54:59 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: David Miller <davem@davemloft.net>
CC: <Trond.Myklebust@netapp.com>, <joe@perches.com>, <bfields@fieldses.org>,
        <neilb@suse.de>, <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
References: <cover.1314650069.git.joe@perches.com> <8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com> <20110829.143751.1153162956919885670.davem@davemloft.net>
In-Reply-To: <20110829.143751.1153162956919885670.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/29/2011 02:37 PM, David Miller wrote:
> From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> Date: Mon, 29 Aug 2011 14:36:17 -0700
> 
>> Big NACK...
>>
>> By whose standard are those "not useful"?
> 
> By mine, that's for sure.  It's duplicating something that the allocation
> layers are already going to print.

I have a question about that. Are the dprints going to show the stack backtrace?
Otherwise how can I see which exact allocation failed and was not properly handled?

If yes above? then I'm not sure I like it either, because am I'll be getting a full
stack backtrace for every failed allocation?

But I might like it if I try. How do I turn on allocation failures prints?
Can I filter out to print only GFP_KERNEL failures and or other GFP combinations?

Thanks 
Boaz
