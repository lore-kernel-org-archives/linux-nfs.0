Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59218 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005Ab1LYEhu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Dec 2011 23:37:50 -0500
Received: by eekc4 with SMTP id c4so10401314eek.19
        for <linux-nfs@vger.kernel.org>; Sat, 24 Dec 2011 20:37:49 -0800 (PST)
Message-ID: <4EF6A898.2010207@tonian.com>
Date: Sun, 25 Dec 2011 06:37:44 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de, Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Session timeout on RHEL6.2
References: <CAGue13pWcOKeQH9nr=VK2ZCMLpC2s1=yQwuyxAEuuizjSh1Z+g@mail.gmail.com> <1324475851.7709.12.camel@lade.trondhjem.org> <CAGue13pSKnxNK_UWnh0KXz_w-CbeWQjmDS1H7ZBVMRiV25JqmQ@mail.gmail.com>
In-Reply-To: <CAGue13pSKnxNK_UWnh0KXz_w-CbeWQjmDS1H7ZBVMRiV25JqmQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-21 22:11, Tigran Mkrtchyan wrote:
> On Wed, Dec 21, 2011 at 2:57 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
>> On Wed, 2011-12-21 at 10:24 +0100, Tigran Mkrtchyan wrote:
>>> Dear friends,
>>>
>>> We are observing strange behavior with RHEL 6.2:
>>>
>>> Our the server lease time is 90 seconds. I can see that client
>>> sends SEQUENCE every 60 sec. And this is for some hours ( ~8 ).
>>> At some point client sends SEQUENCE after 127 seconds and
>>> gets, as expected, EXPIRED.
>>
>> Why shouldn't the client be allowed to let the lease expire if nothing
>> is using that filesystem?
>>
>>> I this point I have to blame myself.
>>> Client comes with EXCHANGE_ID using the same clientid.
>>> We did not garbage collected clientid internally as this happens after
>>> 2*LEASE_TIME
>>> and return EXPIRE. This ping-pong never ends.
>>>
>>> This is probably mostly a bug on my side. Nevertheless we never observed late
>>> SEQUENCE with kernel > 2.6.39. A short packet dump attached.
>>>
>>> I can open bug at RHEL if required.
>>
>> I wouldn't consider that a bug.
> 
> As I said, there is a bug in exchange_id processing ( case 3 ) on my
> side. But to me it's sounds strange that client after more than 8
> hours of sending only sequence decided to send one of them later than
> lease time. Especially, that we did not have it with other kernels.

I'm inclined to agree.  The client can let the lease expire for sure
and that's not a bug but the fact that the client sent the SEQUENCE operation
after the lease had expired indicates it might not be aware of that fact
and that seems to be a client bug.

That said, I don't think that letting the lease expire when the client is idle
is the most polite thing to do. Why let the server clean up after the client
and revert to possibly un-optimized recovery paths rather than orderly
destruction of the state by the client?

Benny

> 
> Anyway, we will update our server tomorrow with bugfix.
> 
> Tigran.
> 
>>
>> Trond
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>>
