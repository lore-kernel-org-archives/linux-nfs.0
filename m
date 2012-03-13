Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48271 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159Ab2CMSxr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 14:53:47 -0400
Received: by yenl12 with SMTP id l12so892125yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2012 11:53:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120313144214.GB16920@science-computing.de>
References: <20120312200221.GS29573@science-computing.de>
	<CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com>
	<5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de>
	<CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com>
	<20120313144214.GB16920@science-computing.de>
Date: Tue, 13 Mar 2012 14:53:46 -0400
Message-ID: <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com>
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
From: Kevin Coffman <kwc@umich.edu>
To: Michael Weiser <M.Weiser@science-computing.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 10:42 AM, Michael Weiser
<M.Weiser@science-computing.de> wrote:
> Hello Kevin,
>
> On Tue, Mar 13, 2012 at 09:51:46AM -0400, Kevin Coffman wrote:
>
>> >> To summarize, the base issue was not with gssd/svcgssd.  It was a
>> >> change in the Kerberos library code (if I recall correctly, in 1.7 or
>> >> 1.8??) which ignores the limited enctypes in the server's keytab, and
>> >> instead uses the Kerberos library's capabilities to assert a subkey.
>> > Are you asking or telling?
>> I'm telling about what happened.  I don't recall what version the
>> change was introduced.
>
>> > From my understanding up until RFC 4537 (Kerberos Cryptosystem Negotiation
>> > Extension - which I hadn't heard of up until the day before yesterday), a
>> > kerberised service had no mechanism to negotiate a ticket or session key
>> > enctype with the client. This limitation is inherent to the Kerberos
>> > protocol since the KDC at the time of creating both has no way of asking
>> > the service which encryption types it currently supports. Instead, when
>> > adding the service to the realm, a set of keys is put on the KDC and into
>> > the service's keytab, thus only indirectly telling both, what enctypes the
>> > service supports.
>> Prior to the change, the KDC knew what enctypes were in the service's
>> keytab and would limit the enctypes negotiated for the service.  After
>> the change, the service asserts enctypes based on the Kerberos
>> library's capabilities, not on what the service can actually handle.
>
> Do you mean the introduction of subkey negotiation on the client side
> without support for limiting the enctypes on the server side which was
> corrected by mit-krb5 1.9.1 and your commit
> d6c1b35c6b40243bfd6fba2591c9f8f2653078c0 to nfs-utils?

Hi Michael,

My understanding of the subkey negotiation is that the subkey is
asserted by the server, not the client.  If the client says it only
supports DES, then that will indeed limit what subkey the server's
Kerberos library will assert.

> Then I understand now, what you meant. With your fix, subkey negotiation
> should indeed work nicely if I have at least MIT Kerberos 1.7 and
> nfs-utils-1.2.3 on the client and MIT Kerberos 1.9.1 and nfs-utils-1.2.4
> on the server. (It does however not do so with current Debian packages
> that have both fixes backported to MIT Kerberos 1.8.3 and
> nfs-utils-1.2.2, but that's a different story.)
>
> Unfortunetely all this is not my actual problem: What I'm seeing is that
> gssd of nfs-utils-1.2.3 no longer limits itself to Single DES session
> keys causing grief for an svcgssd that runs on a kernel that doesn't
> support anything other than Single DES. This is not due to subkey
> negotiation because the server only has MIT Kerberos 1.6 and
> nfs-utils-1.0.9 which don't even support it. It is also not due to a
> change on the KDC: All clients have always had aes256 and arcfour keys
> in their keytabs and as long as they have older versions of nfs-utils
> they work just fine with them.
>
> For this case I need to limit gssd to Single DES *for session keys only*
> even though it wants to do more. Since subkey negotiation can't be used
> since Kerberos and nfs-utils on the server are too old, I need to do it
> on the client.
>
> You are right: I could limit the encryption types on the KDC and in the
> client's keytab to Single DES. The nfs-utils gssd has however for some
> time been bright enough to get tickets with stronger encryption types
> but only Single DES session keys inside. I'd like to preserve that
> behaviour because I expect it has a noticeable security impact.
>
> It also has an administrative impact: Nowadays, Active Directory needs a
> change to the security policy to even hand out Single DES encrypted
> tickets while it is perfectly happy to hand out arcfour tickets with
> Single DES session keys inside (without a change to the policy). So
> basically, the new behaviour of nfs-utils' gssd will cause grief for NFS
> administrators in AD environments while it would continue to work with
> only client-side changes if the old gssd behaviour could be forced
> somehow. I expect it's the same with any newly set-up MIT or Heimdal KDC
> that has Single DES disabled by default.
>
>> I don't object to your change, but will assert that your suggested
>> solution does not handle non-Linux clients attempting to use the RHEL5
>> server.
>
> As far as I can see, this has always been the case: A solaris client
> presenting a RHEL5 server with an arcfour session key would not be able
> to mount. So I guess for Solaris clients I'd already have limited
> encryption types on the KDC to Single DES so that the Solaris client
> only gets Single DES session keys *and tickets*. Or the Solaris client
> has logic similar to what gssd used to do which limits the session key
> type to Single DES. I'll ask a collegue who actually runs a Solaris box
> to see what it's doing.
>
> Thanks for your patience,
> Micha

The way things should work is that the client limits what enctypes it
negotiates based on the enctypes it can handle.  The server does the
same.

Before subkeys, the way to limit the enctypes on the server was to
issue the keytab with only the enctypes supported.  The KDC knew what
types were included in the server's keytab and issued the ticket with
a session key with that limitation in mind.  The extra code to limit
enctypes was added to the client because it had no such mechanism.

After subkeys, the server's keytab enctypes are still honored by the
KDC, however the server's Kerberos libraries assert a subkey based on
the enctypes supported by the libraries, ignoring the enctypes in the
keytab.  That required the additional support to limit the enctypes on
the server side as well.

It sounds like you are saying that your RHEL5 NFS server has a keytab
with more than a DES key.  If that is true, I think that is the issue.
 Not with the clients.

K.C.
