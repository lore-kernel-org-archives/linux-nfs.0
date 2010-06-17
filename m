From: Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: Help please
Date: Thu, 17 Jun 2010 23:46:19 +1000
Message-ID: <AANLkTimMGgIchvP4MoWf2T1lXZNLked1hpwcQ4MTcL7Y@mail.gmail.com>
References: <AANLkTinQkRf_ZkN5qw1rsK5MY7pB1NjFd5CiLaPa-ZOU@mail.gmail.com>
	<1276607740.4922.2.camel@heimdal.trondhjem.org>
	<AANLkTinPbTJ7xrcCHnAP54OKjY5HjZjmA4H4zJjFmeqf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56506 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759762Ab0FQNqW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 09:46:22 -0400
Received: by iwn9 with SMTP id 9so6799133iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 06:46:20 -0700 (PDT)
In-Reply-To: <AANLkTinPbTJ7xrcCHnAP54OKjY5HjZjmA4H4zJjFmeqf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 10:42 PM, Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org> w=
rote:
> On Tue, Jun 15, 2010 at 11:15 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
>> On Tue, 2010-06-15 at 12:01 +1000, Alexander Samad wrote:
>>> Hi
>>>
>>> sorry if this is a duplicate, I have been having some problem
>>> subscribing to the ml.
>>>
>>>
>>>
>>> I am having some problem with nfs-kernel on a debian amd64 (sid) =A0=
i am
>>> using version (1:1.2.2-1).
>>>
>>> when I do a tcpdump on my nfs machine and do a mount -o vers=3D4,ud=
p
>>> nfs:/exports/video /exports/video/ it fails
>>
>> UDP transport is not supported by the NFSv4 protocol. Some servers m=
ay
>> allow it, but most will not.
>
> okay, but why does the nfs-kernel on linux look like it is sending
> packets (via udp), but they are not hitting the wire.

Okay I have vers=3D4, tcp working.

But I would like to have UDP, I had issues with laptop that were
asleep (hibernating) and then unable to reconnect when I restart the
laptop - sometimes because the nfs server needed a reboot etc...  With
udp I don't have these problems.

So i have done some more testing.

I have enabled nfs on another server, with the same package revisions
as my primary nfs server. Say server max is original nfs the one not
working and nas is the newer one.

if I do this on nas
exportfs -o async,ro  192.168.8.0/22:/mnt/tmp

I can do this on max
mount -o vers=3D4,udp,ro,async nas:/mnt/tmp/ /mnt/tmp/

but I can't do the reverse.

I have tried rebooting max into difference kernel revisions -
currently using 2.6.34, tried 6.32 and 6.30 - all failed.

the pain is this used to work.

What I see is the same flow of packets but from max I see the outbound
ack, but it doesn't hit the wire.

which makes me sort of think this might not be he right ml :(   but I
tried different kernels....

thanks
frustrated


>
>
>>
>> Cheers
>> =A0Trond
>>
>>
>
