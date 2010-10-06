Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38417 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011Ab0JFJq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Oct 2010 05:46:57 -0400
Message-ID: <4CAC4585.2040908@parallels.com>
Date: Wed, 06 Oct 2010 13:46:45 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Remove useless if (task == NULL) from xprt_reserve_xprt
References: <4CAB5694.5030400@parallels.com> <20101005224608.GA24954@fieldses.org>
In-Reply-To: <20101005224608.GA24954@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/06/2010 02:46 AM, J. Bruce Fields wrote:
> On Tue, Oct 05, 2010 at 08:47:16PM +0400, Pavel Emelyanov wrote:
>> The task in question is dereferenced above (and is actually never NULL).
> 
> Makes sense to me.
> 
> (But probably it should go through Trond unless there's some dependency
> on your patches in my tree.)

No, no dependency at all. It's OK if this goes through Trond's tree.

> --b.
> 
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> ---
>>  net/sunrpc/xprt.c |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 953206d..64a4a94 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -199,8 +199,6 @@ int xprt_reserve_xprt(struct rpc_task *task)
>>  	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
>>  		if (task == xprt->snd_task)
>>  			return 1;
>> -		if (task == NULL)
>> -			return 0;
>>  		goto out_sleep;
>>  	}
>>  	xprt->snd_task = task;
>> -- 
>> 1.5.5.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> .
> 

