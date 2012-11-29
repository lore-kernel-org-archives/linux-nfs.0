Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:47395 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab2K2Qj2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 11:39:28 -0500
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	<CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	<1354202525.4064.1.camel@pico.ipa.ssimo.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
Date: Thu, 29 Nov 2012 17:39:27 +0100
Message-ID: <CANXojcys4wR8N-R3oSjWRWJLsObn0Qf+i41vBUaNnJctdcrKVw@mail.gmail.com>
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
> On Thu, 2012-11-29 at 10:22 -0500, simo wrote:
>> On Thu, 2012-11-29 at 15:49 +0100, Stef Bon wrote:
>> > 2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
>> > >> -----Original Message-----
>> > >>
> NFSv4.1 actually has directory notifications which duplicate most of the
> functionality of dnotify. The question I'm asking is "Why should we do
> it?", not "can we do it?".
>
> Answers like "well Windows and iOS do it" aren't helpful unless they
> include a description of what Windows and iOS apps use it for that we
> can't already do on Linux.
> If the only application is beagle, then Linux has this really helpful
> utility called "ssh", which allows you to avoid wasting a load of
> network bandwidth...

No, sure, you should not do anything because others do it. But on the
other hand, if others do it, why don't you? Better copy a good idea
than be stubborn for ever.

And yes there is no such thing as a killer app, but in my opinion it's
the user experience. It's so much better when your system keeps track
on shared network resources.

But first things first,I will try to make the first option work, which
was the use of a remote notifyfs server. This works of course only
with linux like systems: so not when the remote server is a Windows
server.

I know that SMB (2?) has the ability to send a SMB2_CHANGE_NOTIFY
request. Steve French and I had earlier a conversation about that.

Before trying to make this work with cifs I've tried to make this work
using a FUSE fs with libsmbclient. I did not get it working since the
adding of an fd to the FUSE fs's eventloop was not easy, and required
a rewrite of libsmbclient.
The writing of the FUSE fs was easy, since there are already some examples.

Stef
