Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43441 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841Ab2CHVNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Mar 2012 16:13:07 -0500
Message-ID: <4F5920B0.4000403@panasas.com>
Date: Thu, 8 Mar 2012 13:12:16 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Return the delegation if the server returns
 NFS4ERR_OPENMODE
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu> <1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com> <1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com> <1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com> <CAN-5tyG-w+ie3sxTwNA6e9x=CojxyDaJScJuCbS+9VE=yTmJNA@mail.gmail.com> <1331230525.2472.39.camel@lade.trondhjem.org> <CAN-5tyFYE5ECtv__C9S_GMT1gBMQ4+6WPS-1BjmSE7vHoRAQdw@mail.gmail.com> <20120308204205.GB9273@fieldses.org> <1331239814.11759.1.camel@lade.trondhjem.org> <20120308205737.GC9273@fieldses.org>
In-Reply-To: <20120308205737.GC9273@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/08/2012 12:57 PM, J. Bruce Fields wrote:
> On Thu, Mar 08, 2012 at 08:50:14PM +0000, Myklebust, Trond wrote:
>> On Thu, 2012-03-08 at 15:42 -0500, J. Bruce Fields wrote:
>>> On Thu, Mar 08, 2012 at 03:23:34PM -0500, Olga Kornievskaia wrote:
>>>> On Thu, Mar 8, 2012 at 1:15 PM, Myklebust, Trond
>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>> On Thu, 2012-03-08 at 12:52 -0500, Olga Kornievskaia wrote:
>>>>>> wouldn't it be better for you to proactively return a read delegation
>>>>>> then unnecessarily erroring?
>>>>>
>>>>> If nobody else holds a delegation, then the NFS client is actually
>>>>> allowed to keep its read delegation while writing to the file. It does
>>>>> admittedly need to request an OPEN stateid for write in that case...
>>>>> (See section 10.4 of RFC3530bis draft 16)
>>>>
>>>> If we both agree that there has to be a request for an open stateid for
>>>> a write, then instead of returning the read delegation if the client receives
>>>> err_openmode (when it send the request with read delegation stateid
>>>> as you said per 3560bis), can't the client resend the setattr with the open
>>>> stateid? The ordering of the stateid usage is a "should" and not a "must".
>>>>
>>>> In rfc5661, it really doesn't make sense to ever send a setattr with
>>>> a read delegation stateid. According to 9.1.2, the server "MUST" return
>>>> err_open_mode" error in that case.
>>>>
>>>> I gather you are in this case dealing with 4.0 delegations. But I wonder
>>>> if you'll do something else for 4.1 delegation then?
>>>
>>> 3530bis has the same language ("...must verify that the access mode
>>> allows writing and return an NFS4ERR_OPENMODE error if it does not").
>>
>> OK, so we shouldn't send the delegation stateid either for v4 or v4.1.
>> However should we pre-emptively return the delegation? I've been
>> assuming not.
> 
> The server's only legal option is to recall it, so it seems odd not to
> pre-emptively return--

Also from the client that sent the setattr? I, as Trond, understood that
the read delegation must be recalled from all clients but the one
doing the setattr/write.

other wise what does it mean:
 "allowed to keep its read delegation while writing to the file"

I think the server should filter out it's global recall to dis-include
the caller.

Though I agree that the client must get a writable stateid for
setattr, and should not use it's  read-delegation-stateid

> but as you say there's nothing to prevent the
> server from then handing one right back, possibly before you get a
> chance to send the setattr.
> 

The above recall filtering will solve that. I know that in layout recalls
we have such facility, and we actually use it in RAID5 exofs.

> (And the linux server might well do that--maybe it should have some
> heuristic not to hand out a delegation that was just returned--not so
> much for this case as just because a return is a sign that the
> delegation isn't useful to that client.)
> 

Thanks
Boaz

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

