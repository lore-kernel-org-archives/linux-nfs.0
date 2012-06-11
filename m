Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48521 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab2FKQ00 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 12:26:26 -0400
Message-ID: <4FD61C15.3060601@panasas.com>
Date: Mon, 11 Jun 2012 19:25:57 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: bfields <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, Steve Dickson <steved@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Platte <jplatte@naasa.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net> <4FD5F35A.3000903@panasas.com> <4FD5F629.1070508@panasas.com> <20120611102947.229cf077@corrin.poochiereds.net> <4FD60839.3000508@panasas.com> <20120611151511.GH7654@fieldses.org>
In-Reply-To: <20120611151511.GH7654@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 06:15 PM, bfields wrote:

> On Mon, Jun 11, 2012 at 06:01:13PM +0300, Boaz Harrosh wrote:
>> On 06/11/2012 05:29 PM, Jeff Layton wrote:
>>
>>> On Mon, 11 Jun 2012 16:44:09 +0300
>>> Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>
>>>> On 06/11/2012 04:32 PM, Boaz Harrosh wrote:
>>>>
>>>>> On 06/11/2012 03:39 PM, Jeff Layton wrote:
>>>>>
>>>>>>>
>>>>>>> But I'm guessing we were wrong to assume that existing setups that
>>>>>>> people perceived as working would have that path, because the failures
>>>>>>> in the absence of that path were probably less obvious.
>>>>>>>
>>>>
>>>>
>>>> One more thing, the most important one. We have already fixed that in the
>>>> past and I was hoping the lesson was learned. Apparently it was not, and
>>>> we are doomed to do this mistake for ever!!
>>>>
>>>> What ever crap fails times out and crashes, in the recovery code, we don't
>>>> give a dam. It should never affect any Server-client communication.
>>>>
>>>> When the grace periods ends the clients gates opens period. *Any* error
>>>> return from state recovery code must be carefully ignored and normal
>>>> operations resumed. At most on error, we move into a mode where any
>>>> recovery request from client is accepted, since we don't have any better
>>>> data to verify it.
>>>>
>>>> Please comb recovery code to make sure any catastrophe is safely ignored.
>>>> We already did that before and it used to work.
>>>>
>>>
>>> That's not the case, and hasn't ever been AFAICT. The code has changed
>>> a bit recently, but the existing behavior in this regard was preserved.
>>> From nfs4_check_open_reclaim:
>>>
>>>         return nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
>>>
>>> ...if there is no client record, then the reclaim request fails. Doesn't
>>> the RFC mandate that?
>>>
>>
>>
>> Regardless of what RFC mandates and what is returned to client, (Which sounds
>> very unrobust to me) I'm sure the client handles nfserr_reclaim_bad just
>> fine.
>>
>> It's the server that's getting stuck in its own feet and stops responding.
>> That's what I meant. We should always resume normal operations after
>> the grace period ends.
>>
>> I did not see any reports of client getting into trouble because of
>> unexpected nfserr_reclaim_bad, did you?
> 
> We did have a few bugs in that area, and as far as I know they're fixed
> (and have stayed fixed!).
> 
> The one other thing we've seen at testing events is clients not sending
> reclaim_complete: not only is it mandatory (with state to reclaim or
> not), it's actually mandatory for servers to fail further operations
> until it's sent.  However the problems were all seen with unreleased
> client code that the implementors said they'd fix.
> 


Yep, I agree. And additionally the bug Jeff fixed (At the other part of this
thread) where the recovery code managed to tromp all over the laundromat thread
and cause the Server to freeze.

I guess it's unavoidable. Bugs will always exist with new code. We should just
re audit  the state recovery code in parts where it shares resources with regular
code, that errors are handled cleanly, like in Jeff's patch above.

> --b.


Thanks
Boaz
