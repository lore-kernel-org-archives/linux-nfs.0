Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:44898 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab2K2UKr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 15:10:47 -0500
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B32B2A0@SACEXCMBX04-PRD.hq.netapp.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	<CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	<1354202525.4064.1.camel@pico.ipa.ssimo.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
	<CANXojcys4wR8N-R3oSjWRWJLsObn0Qf+i41vBUaNnJctdcrKVw@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B32B2A0@SACEXCMBX04-PRD.hq.netapp.com>
Date: Thu, 29 Nov 2012 21:10:46 +0100
Message-ID: <CANXojczr0guTAc7-yq=wZGcKsYy9x=k_Q-P_OzkJHptcdHYtOg@mail.gmail.com>
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
From: Stef Bon <stefbon@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: simo <idra@samba.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
> On Thu, 2012-11-29 at 17:39 +0100, Stef Bon wrote:
>> 2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
>> > On Thu, 2012-11-29 at 10:22 -0500, simo wrote:
>> >> On Thu, 2012-11-29 at 15:49 +0100, Stef Bon wrote:
>> >> > 2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
>> >> > >> -----Original Message-----
>> >> > >>

>>
>> No, sure, you should not do anything because others do it. But on the
>> other hand, if others do it, why don't you? Better copy a good idea
>> than be stubborn for ever.
>
> The idea that "if we build a bridge, they will come to us" is what gave
> rise to dnotify, then inotify (nobody came, so let's build a bigger
> bridge) and fsnotify (make it a toll bridge). Nobody is using those
> interfaces much on local filesystems, so why is adding it to NFS and
> CIFS going to be such a game changer?

Well that's a good question. I've been working on this issue for some
time now, and do not find much interest in it. I do not understand!

Although I find this a bit frustating, I still beleive it's a good
feature.  And yes, I believe that what you suggest with building a
bridge (having a good idea) they will come to us.

And I've [posted on qt dev platforms, and they mentioned me that they
need much more fine grained methods, that just "something has
changed". But ok, that has nothing to do with nfs ...


>
>> And yes there is no such thing as a killer app, but in my opinion it's
>> the user experience. It's so much better when your system keeps track
>> on shared network resources.
>
> What does it enable us to do that we can't already do? This is precisely
> the question that I asked you in the previous email.

Huh? Is it possible to monitor directories and other objects for
changes already with network fs's??

By polling? The poor mans fs notify service?

Stef
