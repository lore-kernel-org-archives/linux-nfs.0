Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44191 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627Ab3BLGtm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Feb 2013 01:49:42 -0500
Message-ID: <5119E5E8.9030803@parallels.com>
Date: Tue, 12 Feb 2013 10:49:12 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <akpm@linux-foundation.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@netapp.com>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH 0/2] NFSD: fix races in service per-net resources allocation
References: <20130201111046.24066.72836.stgit@localhost.localdomain> <20130211002558.GD10161@fieldses.org> <51188D2A.4070605@parallels.com> <20130211163715.GA19342@fieldses.org>
In-Reply-To: <20130211163715.GA19342@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.02.2013 20:37, J. Bruce Fields пишет:
> On Mon, Feb 11, 2013 at 10:18:18AM +0400, Stanislav Kinsbursky wrote:
>> This one looks a bit complicated and confusing to me. Probably because
>> I'm not that familiar with service transports processing logic.  So,
>> as I can see, we now try to run over all per-net pool-assigned
>> transports, remove them from "ready" queue and delete one by one.
>> Then we try to enqueue all temporary sockets. But where in enqueueing
>> of permanent sockets? I.e. how does they be destroyed with this patch?
>> Then we once again try to run over all per-net pool-assigned
>> transports, remove them from "ready" queue and delete one by one.  Why
>> twice? I.e. why not just lose them, then enqueue them and
>> svc_clean_up_xprts()?
>
> I think you missed the first svc_close_list?:
>

Yeah, thanks! To many deleted lines confused me.

>>>   	svc_close_list(serv, &serv->sv_permsocks, net);
>>> +	svc_clean_up_xprts(serv, net);
>>> +	svc_close_list(serv, &serv->sv_tempsocks, net);
>>> +	svc_clean_up_xprts(serv, net);
>
> The idea is that before we'd like to close all the listeners first, so
> that they aren't busy creating more tempsocks while we're trying to
> close them.
>
> I overlooked a race, though: if another thread was already handling an
> accept for one of the listeners then it might not get closed by that
> first svc_clean_up_xprts.
>
> I guess we could do something like:
>
> 	delay = 0;
>
>      again:
> 	numclosed = svc_close_list(serv, &serv->sv_permsocks, net);
> 	numclosed += svc_close_list(serv, &serv->sv_tempsocks, net);
> 	if (numclosed) {
> 		svc_clean_up_xprts(serv, net);
> 		msleep(delay++);
> 		goto again;
> 	}
>
> Seems a little cheesy, but if we don't care much about shutdown
> performance in a rare corner case, maybe it's the simplest way out?
>

Agreed. This part (per-net shutdown) has enough logical complexity already and would be great to not
increase it.


-- 
Best regards,
Stanislav Kinsbursky
