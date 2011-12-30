Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44196 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab1L3L1i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Dec 2011 06:27:38 -0500
Received: by wibhm6 with SMTP id hm6so6876594wib.19
        for <linux-nfs@vger.kernel.org>; Fri, 30 Dec 2011 03:27:36 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C9E2CBF@SACMVEXC2-PRD.hq.netapp.com>
References: <CAGue13pWcOKeQH9nr=VK2ZCMLpC2s1=yQwuyxAEuuizjSh1Z+g@mail.gmail.com>
	<1324475851.7709.12.camel@lade.trondhjem.org>
	<CAGue13pSKnxNK_UWnh0KXz_w-CbeWQjmDS1H7ZBVMRiV25JqmQ@mail.gmail.com>
	<4EF6A898.2010207@tonian.com>
	<1324806463.2740.6.camel@lade.trondhjem.org>
	<4EF71125.1060901@tonian.com>
	<1324819508.5195.8.camel@lade.trondhjem.org>
	<CAGue13r92miL8cyY_=ag1yLbwmmcMJeAGtMxTjshvST=44SP=A@mail.gmail.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C9E2CBF@SACMVEXC2-PRD.hq.netapp.com>
Date: Fri, 30 Dec 2011 12:27:36 +0100
Message-ID: <CAGue13qbh1_97EZ80mt_YdKM5WKZ2hNigyTr_FkJcv-E2S_2mA@mail.gmail.com>
Subject: Re: Session timeout on RHEL6.2
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 30, 2011 at 2:03 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: Tigran Mkrtchyan [mailto:tigran.mkrtchyan@desy.de]
>> Sent: Thursday, December 29, 2011 8:21 PM
>> To: Myklebust, Trond
>> Cc: Benny Halevy; linux-nfs
>> Subject: Re: Session timeout on RHEL6.2
>>
>> Hi Trond,
>>
>> There is a small inconsistency in your theory: to close idle session it's enough
>> not to send sequence any more and there are no reason to re-establish
>> session as soon as server returns EXPIRED.
>
> I don't understand. I've never put forward any "theory" involving forcing the client to re-establish the session just because the server returns EXPIRED. It should be re-establishing sessions iff we want to access the filesystem and the server tells it that the session expired.

My apologies if I was not clear. I just wanted to say that it doesn't
looks like expected client behavior.

Tigran.

>
> Trond
>
>
>> Tigran.
>>
>> On Sun, Dec 25, 2011 at 2:25 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Sun, 2011-12-25 at 14:03 +0200, Benny Halevy wrote:
>> >> On 2011-12-25 11:47, Trond Myklebust wrote:
>> >> > On Sun, 2011-12-25 at 06:37 +0200, Benny Halevy wrote:
>> >> >> On 2011-12-21 22:11, Tigran Mkrtchyan wrote:
>> >> >>> On Wed, Dec 21, 2011 at 2:57 PM, Trond Myklebust
>> >> >>> <Trond.Myklebust@netapp.com> wrote:
>> >> >>>> On Wed, 2011-12-21 at 10:24 +0100, Tigran Mkrtchyan wrote:
>> >> >>>>> Dear friends,
>> >> >>>>>
>> >> >>>>> We are observing strange behavior with RHEL 6.2:
>> >> >>>>>
>> >> >>>>> Our the server lease time is 90 seconds. I can see that client
>> >> >>>>> sends SEQUENCE every 60 sec. And this is for some hours ( ~8 ).
>> >> >>>>> At some point client sends SEQUENCE after 127 seconds and gets,
>> >> >>>>> as expected, EXPIRED.
>> >> >>>>
>> >> >>>> Why shouldn't the client be allowed to let the lease expire if
>> >> >>>> nothing is using that filesystem?
>> >> >>>>
>> >> >>>>> I this point I have to blame myself.
>> >> >>>>> Client comes with EXCHANGE_ID using the same clientid.
>> >> >>>>> We did not garbage collected clientid internally as this
>> >> >>>>> happens after 2*LEASE_TIME and return EXPIRE. This ping-pong
>> >> >>>>> never ends.
>> >> >>>>>
>> >> >>>>> This is probably mostly a bug on my side. Nevertheless we never
>> >> >>>>> observed late SEQUENCE with kernel > 2.6.39. A short packet
>> dump attached.
>> >> >>>>>
>> >> >>>>> I can open bug at RHEL if required.
>> >> >>>>
>> >> >>>> I wouldn't consider that a bug.
>> >> >>>
>> >> >>> As I said, there is a bug in exchange_id processing ( case 3 ) on
>> >> >>> my side. But to me it's sounds strange that client after more
>> >> >>> than 8 hours of sending only sequence decided to send one of them
>> >> >>> later than lease time. Especially, that we did not have it with other
>> kernels.
>> >> >>
>> >> >> I'm inclined to agree.  The client can let the lease expire for
>> >> >> sure and that's not a bug but the fact that the client sent the
>> >> >> SEQUENCE operation after the lease had expired indicates it might
>> >> >> not be aware of that fact and that seems to be a client bug.
>> >> >>
>> >> >> That said, I don't think that letting the lease expire when the
>> >> >> client is idle is the most polite thing to do. Why let the server
>> >> >> clean up after the client and revert to possibly un-optimized
>> >> >> recovery paths rather than orderly destruction of the state by the
>> client?
>> >> >
>> >> > There are plenty of cases where the client can be idle for hours or
>> >> > even _days_. What's the point of pinging the server all the time
>> >> > after working hours?
>> >> >
>> >> > If someone wants to code up a DESTROY_SESSION and
>> DESTROY_CLIENTID
>> >> > in order to make it formal, then fine, however note that we don't
>> >> > even do that on a full unmount today.
>> >> >
>> >>
>> >> The heavy lifting is releasing locks and returning layouts and
>> >> delegations sending DESTROY_{SESSION,CLIENTID} would be nice to have
>> >> but I don't think it's the most important issue.
>> >
>> > Actually, that requirement to return state is what makes
>> > DESTROY_CLIENTID a completely useless operation.
>> > Forget what I said then: it's too stupid to implement...
>> >
>> > --
>> > Trond Myklebust
>> > Linux NFS client maintainer
>> >
>> > NetApp
>> > Trond.Myklebust@netapp.com
>> > www.netapp.com
>> >
