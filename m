Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcbbj.dreamhost.com ([208.97.132.119]:45717 "EHLO
	homiemail-a90.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933609Ab1KCS5O convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 14:57:14 -0400
Received: from homiemail-a90.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a90.g.dreamhost.com (Postfix) with ESMTP id EB4762AC077
	for <linux-nfs@vger.kernel.org>; Thu,  3 Nov 2011 11:57:13 -0700 (PDT)
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a90.g.dreamhost.com (Postfix) with ESMTPSA id B865A2AC073
	for <linux-nfs@vger.kernel.org>; Thu,  3 Nov 2011 11:57:13 -0700 (PDT)
Received: by vcge1 with SMTP id e1so1419578vcg.19
        for <linux-nfs@vger.kernel.org>; Thu, 03 Nov 2011 11:57:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320337903.7734.670.camel@willson.li.ssimo.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	<CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	<1320332310.7734.643.camel@willson.li.ssimo.org>
	<CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	<1320337903.7734.670.camel@willson.li.ssimo.org>
Date: Thu, 3 Nov 2011 13:57:12 -0500
Message-ID: <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>,
        dhowells <dhowells@redhat.com>,
        =?UTF-8?B?TG92ZSBIw7ZybnF1aXN0IMOFc3RyYW5k?= <lha@kth.se>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 3, 2011 at 11:31 AM, Simo Sorce <simo@redhat.com> wrote:
> On Thu, 2011-11-03 at 11:05 -0500, Nico Williams wrote:
>> If the proxy daemon process dies, how should the proxy client recover?
>
> Either wait for the proxy to restart or treat it as an unrecoverable
> error, just like if the network goes away ?

If state is lost the client has to recover.  Sure, it's going to
somehow (perhaps by returning an error to the user, who then retries).
 Point is: a stateless (or stateless + caching, for perf) design would
avoid this.

For the protocol that just means that handles need to be opaque octet
strings, NOT just small integers.  Whether a given implementation is
stateless is another story.  This is what I was driving at.

> Ok, I can see how this may help.

:)

>> There's no complication.  The protocol needs to allow for
>> arbitrary-sized object handles -- that's all.
>
> Ok, I was complaining about making the server more complicated, but
> that's probably not really true, we will just trade one set of issues
> with another as the state is kept 'somewhere' anyway, so I retire my
> concern.

Right.

>> I'd much rather not have to pass anything, but we need to support OSes
>> where that's just how it's done.  I'd rather that IPC end-points can
>> find out what what they need about their peers.  Think
>> door_ucred(3DOOR).
>
> I don't think I want to use the PID and then try to pull out environment
> variables through /proc or similar interface, that would be bad.

I would never have suggested that.

What I had in mind was something like PAGs or keyrings.  Or, to be
much more specific, search for my name and the string "credentials
process groups" -- a PAG on steroids.

The idea is that the IPC peer can observe the other's
PAG/keyring/CPG/whatever and use that to find the correct credentials
(authorization is still required though).

> For the krb5 mech we only care about a handful of environment variables.

And for others?  Anyways, environment variables -> ewwww.

>> Trust nothing.  Authorization is separate.
>
> That depends on the client.
> When the client is the kernel we can decide to trust whatever it says.

Of course.  But if at all possible the mechanism for identifying the
correct credentials stores should be the same for kernel and
non-kernel consumers (see above).

>> Indeed, I'm not interested in dictating implementation details.  It's
>> going to be very difficult to avoid discussing possible implementation
>> details, so I don't bother trying not to :)  But the protocol itself
>> needs to be agnostic regarding these things.
>
> ACK

:)

I use possible implementation choices to inform/motivate/justify
protocol design choices.

>> Multi-threaded is fine.  On Solaris it'd have to be multi-processed
>> because it's not possible to have different process credentials for
>> different threads of the same process in Solaris -- ias with this in
>> mind that I mentioned the possible [implementation-specific detail of
>> a] design where there's a daemon process per {user session}, {user,
>> label}, ...
>
> I am not sure you need that separation, but as it is an implementation
> detail I think we should set discussion around this aside for now.

Sure.  But without separation, and using the true GSS API, there's no
way to pass the authorization context to the GSS-API, so that
leaves... impersonating the user, which is either not thread safe (in
POSIX) or not standard (or Windows).  This is context that I left out
when I posted (it was late :/).

> It is ok to agree that any time we mention implementation details of the
> proxy itself these are not binding, but just a tool to explain why
> something may be needed.

Good.

>> >>  - The protocol probably need not be straight up ONC RPC however,
>> >> though where ONC RPC supports suitable IPC interfaces as transports,
>> >> it'd certainly be worth considering.
>> >
>> > We definitely MUST NOT require ONC RPC for the protocol, if someone
>> > wants to use it for something specific and build it on our work I am
>> > quite fine and I do not want to prevent it. But I thikn we do not want
>> > to force all that overhead on Kernels and other implementations by
>> > default as we do not really need it for a local daemon.
>>
>> ONC RPC has next to no overhead when the transport is something like
>> doors, for example.
>
> I mean conceptual and development over head, not talking about
> performance.

If you don't need rpcbind/portmapper (and you don't for local non-IP
IPC) then the conceptual overhead is zero.  The Solaris kernel kidmap
module uses RPC over doors without any RPC runtime code on the
client-side -- it's just XDR -- it can be done.

Nico
--
