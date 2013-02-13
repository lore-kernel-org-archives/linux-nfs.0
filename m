Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:50037 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab3BMFQc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2013 00:16:32 -0500
Message-ID: <511B2190.2050006@parallels.com>
Date: Wed, 13 Feb 2013 09:16:00 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Peter Staubach <pstaubach@exagrid.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/2] NFSD: fix races in service per-net resources allocation
References: <20130201111046.24066.72836.stgit@localhost.localdomain> <20130211002558.GD10161@fieldses.org> <51188D2A.4070605@parallels.com> <20130211163715.GA19342@fieldses.org> <20130211205845.GE30117@fieldses.org> <511A10E0.1000604@parallels.com> <20130212204533.GD10267@fieldses.org> <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C5DF98826@IT-1874.Isys.com>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C5DF98826@IT-1874.Isys.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

13.02.2013 01:18, Peter Staubach пишет:
> The "+" thing seems a little odd.  Why not use "||" instead?  The sum of the two returns isn't really the important thing, is it?  It is that either call to svc_close_list() returns non-zero.
>
> 	Thanx...
>

Yep, thanks for the notice.

> 		ps
>
>
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Tuesday, February 12, 2013 3:46 PM
> To: Stanislav Kinsbursky
> Cc: akpm@linux-foundation.org; linux-nfs@vger.kernel.org; Trond.Myklebust@netapp.com; linux-kernel@vger.kernel.org; devel@openvz.org
> Subject: Re: [PATCH 0/2] NFSD: fix races in service per-net resources allocation
>
> On Tue, Feb 12, 2013 at 01:52:32PM +0400, Stanislav Kinsbursky wrote:
>> 12.02.2013 00:58, J. Bruce Fields пишет:
>> <snip>
>>>   void svc_close_net(struct svc_serv *serv, struct net *net)
>>>   {
>>> -	svc_close_list(serv, &serv->sv_tempsocks, net);
>>> -	svc_close_list(serv, &serv->sv_permsocks, net);
>>> -
>>> -	svc_clear_pools(serv, net);
>>> -	/*
>>> -	 * At this point the sp_sockets lists will stay empty, since
>>> -	 * svc_xprt_enqueue will not add new entries without taking the
>>> -	 * sp_lock and checking XPT_BUSY.
>>> -	 */
>>> -	svc_clear_list(serv, &serv->sv_tempsocks, net);
>>> -	svc_clear_list(serv, &serv->sv_permsocks, net);
>>> +	int closed;
>>> +	int delay = 0;
>>> +
>>> +again:
>>> +	closed = svc_close_list(serv, &serv->sv_permsocks, net);
>>> +	closed += svc_close_list(serv, &serv->sv_tempsocks, net);
>>> +	if (closed) {
>>> +		svc_clean_up_xprts(serv, net);
>>> +		msleep(delay++);
>>> +		goto again;
>>> +	}
>>
>> Frankly, this hunk above makes me feel sick... :( But I have no better
>> idea right now...
>> Maybe make this hunk a bit less weird (this is from my POW only, of course), like this:
>>
>>> +	while (svc_close_list(serv, &serv->sv_permsocks, net) +
>>> +	       svc_close_list(serv, &serv->sv_tempsocks, net)) {
>>> +		svc_clean_up_xprts(serv, net);
>>> +		msleep(delay++);
>>> +	}
>>
>> ?
>
> OK, that's a little more compact at least.
>
> --b.
>
>>
>> Anyway, thanks!
>>
>> Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>>
>> --
>> Best regards,
>> Stanislav Kinsbursky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Best regards,
Stanislav Kinsbursky
