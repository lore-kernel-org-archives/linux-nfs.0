Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcahe.dreamhost.com ([208.97.132.74]:48625 "EHLO
	homiemail-a88.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933777Ab1KCQFN convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 12:05:13 -0400
Received: from homiemail-a88.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a88.g.dreamhost.com (Postfix) with ESMTP id 7932A26406F
	for <linux-nfs@vger.kernel.org>; Thu,  3 Nov 2011 09:05:13 -0700 (PDT)
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a88.g.dreamhost.com (Postfix) with ESMTPSA id 46938264063
	for <linux-nfs@vger.kernel.org>; Thu,  3 Nov 2011 09:05:13 -0700 (PDT)
Received: by vws1 with SMTP id 1so1022797vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 03 Nov 2011 09:05:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320332310.7734.643.camel@willson.li.ssimo.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	<CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	<1320332310.7734.643.camel@willson.li.ssimo.org>
Date: Thu, 3 Nov 2011 11:05:12 -0500
Message-ID: <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>,
        Andy Adamson <andros@netapp.com>, Steve Dickson <steved@redhat.com>,
        Kevin Coffman <kwc@citi.umich.edu>, Bruce Fields <bfields@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>, Greg Hudson <ghudson@mit.edu>,
        Tom Yu <tlyu@mit.edu>, Sam Hartman <hartmans@mit.edu>,
        dhowells <dhowells@redhat.com>,
        =?UTF-8?B?TG92ZSBIw7ZybnF1aXN0IMOFc3RyYW5k?= <lha@kth.se>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 3, 2011 at 9:58 AM, Simo Sorce <simo@redhat.com> wrote:
> On Wed, 2011-11-02 at 22:24 -0500, Nico Williams wrote:
>>  - We want stateless GSS daemons, or mostly stateless at least, for
>> several reasons:
>>
>>    a) to protect them against DoS, intentional and not;
>
> I get this.
>
>>    b) to make GSS daemon restart a non-event (OK, this is a much
>> lesser concern).
>
> I am not sure I get this one, can you expand.

If the proxy daemon process dies, how should the proxy client recover?
 If the client merely knows about credential handles for credentials
stored in the proxy, then those are invalidated.  If the client has
[encrypted] exported credential handle tokens then the new daemon
process will be able to decrypt and import the client's credential
handles.  Statelessness is helpful.

> Also how do you plan to keep conversations going and still be
> stateless ? I am not sure transferring state back and forth is
> necessarily a good thing.

What I'd like to see is the state cookies passed to the client be
structured something like this (note that this would be an
implementation detail, not part of the protocol spec): {object
reference, verifier cookie, exported object token, [key ID for key
that encrypted the exported token object, if any]}.  This allows for
speed (no need to re-import state all the time) and statelessness (the
server can restart, the server can push state out of a fixed-sized
cache).

>>    This basically requires credential handle export and
>> partially-established security context export support.  It also
>> requires composite name export (to capture name attributes, which
>> won't be captured by normal exported names).
>
> Given one of the aims is to perform privilege separation I wonder if
> exporting partially-established security contexts is going to expose us
> to some risk of disclosing to the application stuff we should not.
> Should we sign/seal each partially established context to avoid
> tampering ?

See above.

> Isn't this going to be quite expensive ?

See above.

>>    Statelessness is not strictly necessary, just highly desirable, so
>> if this proves difficult (or in some cases credential export turns out
>> to not possibly be stateless for some mechanisms/credentials), oh
>> well.  But the *protocol* should be designed to facilitate
>> statelessness, and certainly not preclude it.
>
> I do not want to preclude anything if possible, but I also would like to
> avoid over-complicating it. Being stateless often makes it slower as

There's no complication.  The protocol needs to allow for
arbitrary-sized object handles -- that's all.

> state has to be reconstructed instead of simply being directly
> available. But I guess we will see how it goes during the implementation
> phase. I hear you on the DoS side, but there are other methods to
> prevent DoSs, like rate limiting, etc.

No, rate limiting is a hack.

>>  - I would like mechglues to support mechanisms being provided by
>> multiple providers.  This is tricky, and for some mechanisms it will
>> not be possible to make this perfect, but it's worthwhile  The reason
>> is this: it should be possible to use a proxy for some credentials and
>> not a proxy for others (particularly on the initiator side, where a
>> user may not have direct access to some of their credentials but maybe
>> can always kinit ones that they do have access to).
>
> The initiator side seem more complex indeed, but in general we need to

Let's agree to be careful with client/server vs. initiator/acceptor.
The latter should refer exactly to the GSS meanings of "initiator" and
"acceptor".  The former should refer to the proxy client and server.

> discuss how proxy vs non-proxy is going to be selected. The method may
> differ between initiatior and acceptor as they are objectively different
> cases. And it may differ also based on what app is using libgssapi.

The GSS-API lacks a concept of caller context handl -- an equivalent
to krb5_context.  This is a problem.  We can't speak of who the
application is, not in a world where many libraries use the GSS-API,
because there can be multiple applications in one process and we can't
easily distinguish which application the caller is.

I refer you to past discussions of how to address this.  I really want
to avoid that subject for now though.

> How I am not sure, one of the objectives is to keep this almost
> completely transparent to current user space applications, but I guess
> adding new API to add some sort of awareness is a possibility.
> But we should avoid adding anything unless it really is absolutely
> needed.

I don't entirely agree with this.  Sometimes it's not clear that one
needs X until X is available.  Knowing that X will be necessary is
what we call "vision" :)

>>    This too is a nice to have rather than a critical feature, but if
>> we don't have this then we need to make it possible for all GSS apps
>> to run with just the proxy provider as the one provider (or: the proxy
>> provider *is* the mechglue as far as the application is concerned).
>> Otherwise we can get into situations where a library should use the
>> proxy while another should not, both in the same process, and that
>> could be obnoxious.
>
> Do you have an example in mind, I think it would benefit everyone to
> wrap their minds around these needs/issues if we provide some concrete
> examples here and there.

Layered software.  Particularly pluggable layers like PAM.

>>  - Finding credentials, and authorization, will be a bit of a problem.
>>  How to deal with things like kernel keyrings and KRB5CCNAME-type
>> environment variables?
>>
>>    One possibility is that the proxy client passes everything the
>> proxy server needs to the proxy server.  But that still requires that
>> the proxy server be able to implement authorization correctly.
>
> I think we need to pass everything, and yet the proxy MUST be allowed to

I'd much rather not have to pass anything, but we need to support OSes
where that's just how it's done.  I'd rather that IPC end-points can
find out what what they need about their peers.  Think
door_ucred(3DOOR).

> decide what to trust and what not of course. Also we should not preclude

Trust nothing.  Authorization is separate.

> future developments where the proxy becomes capable of applying policy
> in order to deny some operations. This means we need to make it very
> clear to the other side when an error means it should try to proceed w/o
> the proxy and when an error means the proxy decided to deny the
> operation and so the library should drop everything and return an error.

The protocol itself needs to be generic and allow for passing everything.

>>    For authorization it will be best to run a proxy for each user or
>> {user, session} if there's session isolation, or {user, label} for
>> labeled systems.  This approach helps with finding credentials too.
>
> I do not think we should dictate how the proxy is run. On embedded

Indeed, I'm not interested in dictating implementation details.  It's
going to be very difficult to avoid discussing possible implementation
details, so I don't bother trying not to :)  But the protocol itself
needs to be agnostic regarding these things.

> systems there will be a request to keep it small. I am also not sure
> that forking a process for each user is desirable. It means having a
> process sitting there doing nothing most of the time. The GSSAPI Proxy
> should be considered a very trusted service. I was thinking of a
> multi-threaded design in order to scale when many requests come in at
> once (I am thinking of servers being hit in the morning when all users
> log in roughly at the same time), but that can scale back when load
> spikes are gone.

Multi-threaded is fine.  On Solaris it'd have to be multi-processed
because it's not possible to have different process credentials for
different threads of the same process in Solaris -- ias with this in
mind that I mentioned the possible [implementation-specific detail of
a] design where there's a daemon process per {user session}, {user,
label}, ...

I suppose I need to be more careful in separating what I intend to be
part of a standard and what I intend to be an implementation detail
when I describe these sorts of things.  To me it's clear, but perhaps
not so much to others.

>>  - But the more GSS proxy server daemon processes we have, the more we
>> need to worry about ensuring timely termination.
>
> This is one reason why I do not favor multiple processes per user.

See above.

>>  - Thus the protocol should look very much like an XDR type for each
>> GSS function's input arguments and another for each functions output
>> arguments and return value, plus, for functions dealing in exportable
>> objects, exported objects on input and output, plus, perhaps,
>> environmental / credential location information for certain functions.
>
> Agreed.
>
>>  The environmental / credential location information may not be needed
>> in some operating systems (because the proxy server will be able to
>> use APIs like door_ucred(3DOOR), on Solaris, to find out what it needs
>> about the caller), and in any case will need to be either a typed hole
>> a an opaque type defined by each OS.
>
> I am not sure I really want to care about OSs that cannot ask the kernel
> who's on the other side of a pipe. I would rather let whoever cares
> about those to send patches later, they can be as simple as requiring
> the creation of multiple sockets with appropriate permissions. After all
> if the kernel does not help we cannot make choice of how much trust what
> the user is sending us stuff anyway, either we always trust all or
> nothing in those cases.

I assume all OSes will have something for this, but possibly not
enough, thus the need to pass some environmental context in some
cases.  I want to not preclude that.

>>  - Preferably we should have a set pattern for mapping {argument
>> direction, C type} to/from XDR types that can be applied in an
>> automated fashion to the GSS C bindings header file(s), thus making it
>> possible to avoid having to specify the abstract syntax for the
>> protocol.  I believe this is entirely feasible.
>
> Looks like worth putting some effort into this, would keep stuff simpler
> and leaner.

Yes.

>>  - To make it possible to some day consider the "PGSS" or variant
>> proposals, we should make the representation of the minor_status
>> argument extensible and both, an input and output.
>
> I am not familiar with 'PGSS' care to elaborate if it is really
> something we need to care about ?

Yes, but not right now.  Maybe tonight.

>>  - The protocol probably need not be straight up ONC RPC however,
>> though where ONC RPC supports suitable IPC interfaces as transports,
>> it'd certainly be worth considering.
>
> We definitely MUST NOT require ONC RPC for the protocol, if someone
> wants to use it for something specific and build it on our work I am
> quite fine and I do not want to prevent it. But I thikn we do not want
> to force all that overhead on Kernels and other implementations by
> default as we do not really need it for a local daemon.

ONC RPC has next to no overhead when the transport is something like
doors, for example.

I'm out of time.  More later.

Nico
--
