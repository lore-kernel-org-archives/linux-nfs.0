Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932077Ab1KCO65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 10:58:57 -0400
Subject: Re: GSSAPI Proxy initiative
From: Simo Sorce <simo@redhat.com>
To: Nico Williams <nico@cryptonector.com>
Cc: linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>,
        Andy Adamson <andros@netapp.com>, Steve Dickson <steved@redhat.com>,
        Kevin Coffman <kwc@citi.umich.edu>, Bruce Fields <bfields@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>, Greg Hudson <ghudson@mit.edu>,
        Tom Yu <tlyu@mit.edu>, Sam Hartman <hartmans@mit.edu>,
        dhowells <dhowells@redhat.com>
In-Reply-To: <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	 <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Nov 2011 10:58:30 -0400
Message-ID: <1320332310.7734.643.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-11-02 at 22:24 -0500, Nico Williams wrote:
> Hi Simo,
> 
> As you know, I completely agree that we need this.  We have several
> implementations, of course (in Linux, in Solaris, probably elsewhere,
> such as the BSDs, as well as proprietary ones), but all are -to my
> knowledge- focused on providing services to kernel-mode distributed
> filesystems (AFS, NFS, Lustre -- all come to mind).  But we need to
> generalize this into a service for user-land consumers too, not just
> kernel mode consumers.
> 
> A few thoughts:
> 
>  - XDR is quite fine for this.
> 
>  - We want stateless GSS daemons, or mostly stateless at least, for
> several reasons:
> 
>    a) to protect them against DoS, intentional and not;

I get this.

>    b) to make GSS daemon restart a non-event (OK, this is a much
> lesser concern).

I am not sure I get this one, can you expand.

Also how do you plan to keep conversations going and still be
stateless ? I am not sure transferring state back and forth is
necessarily a good thing.

>    This basically requires credential handle export and
> partially-established security context export support.  It also
> requires composite name export (to capture name attributes, which
> won't be captured by normal exported names).

Given one of the aims is to perform privilege separation I wonder if
exporting partially-established security contexts is going to expose us
to some risk of disclosing to the application stuff we should not.
Should we sign/seal each partially established context to avoid
tampering ?
Isn't this going to be quite expensive ?

>    Statelessness is not strictly necessary, just highly desirable, so
> if this proves difficult (or in some cases credential export turns out
> to not possibly be stateless for some mechanisms/credentials), oh
> well.  But the *protocol* should be designed to facilitate
> statelessness, and certainly not preclude it.

I do not want to preclude anything if possible, but I also would like to
avoid over-complicating it. Being stateless often makes it slower as
state has to be reconstructed instead of simply being directly
available. But I guess we will see how it goes during the implementation
phase. I hear you on the DoS side, but there are other methods to
prevent DoSs, like rate limiting, etc.

>    Note: I really don't want to have an extended sub-thread about
> exporting partially-established sec contexts.  We've had that enough
> at KITTEN WG, so unless you (whoever wants to bring this up) are
> familiar with those threads, please don't bring up the subject, and if
> you must, then please use a separate subject.
> 
>  - I would like mechglues to support mechanisms being provided by
> multiple providers.  This is tricky, and for some mechanisms it will
> not be possible to make this perfect, but it's worthwhile  The reason
> is this: it should be possible to use a proxy for some credentials and
> not a proxy for others (particularly on the initiator side, where a
> user may not have direct access to some of their credentials but maybe
> can always kinit ones that they do have access to).

The initiator side seem more complex indeed, but in general we need to
discuss how proxy vs non-proxy is going to be selected. The method may
differ between initiatior and acceptor as they are objectively different
cases. And it may differ also based on what app is using libgssapi.
How I am not sure, one of the objectives is to keep this almost
completely transparent to current user space applications, but I guess
adding new API to add some sort of awareness is a possibility.
But we should avoid adding anything unless it really is absolutely
needed.

>    This too is a nice to have rather than a critical feature, but if
> we don't have this then we need to make it possible for all GSS apps
> to run with just the proxy provider as the one provider (or: the proxy
> provider *is* the mechglue as far as the application is concerned).
> Otherwise we can get into situations where a library should use the
> proxy while another should not, both in the same process, and that
> could be obnoxious.

Do you have an example in mind, I think it would benefit everyone to
wrap their minds around these needs/issues if we provide some concrete
examples here and there.

>  - Finding credentials, and authorization, will be a bit of a problem.
>  How to deal with things like kernel keyrings and KRB5CCNAME-type
> environment variables?
> 
>    One possibility is that the proxy client passes everything the
> proxy server needs to the proxy server.  But that still requires that
> the proxy server be able to implement authorization correctly.

I think we need to pass everything, and yet the proxy MUST be allowed to
decide what to trust and what not of course. Also we should not preclude
future developments where the proxy becomes capable of applying policy
in order to deny some operations. This means we need to make it very
clear to the other side when an error means it should try to proceed w/o
the proxy and when an error means the proxy decided to deny the
operation and so the library should drop everything and return an error.

>    For authorization it will be best to run a proxy for each user or
> {user, session} if there's session isolation, or {user, label} for
> labeled systems.  This approach helps with finding credentials too.

I do not think we should dictate how the proxy is run. On embedded
systems there will be a request to keep it small. I am also not sure
that forking a process for each user is desirable. It means having a
process sitting there doing nothing most of the time. The GSSAPI Proxy
should be considered a very trusted service. I was thinking of a
multi-threaded design in order to scale when many requests come in at
once (I am thinking of servers being hit in the morning when all users
log in roughly at the same time), but that can scale back when load
spikes are gone.

>  - But the more GSS proxy server daemon processes we have, the more we
> need to worry about ensuring timely termination.

This is one reason why I do not favor multiple processes per user.

>  - Thus the protocol should look very much like an XDR type for each
> GSS function's input arguments and another for each functions output
> arguments and return value, plus, for functions dealing in exportable
> objects, exported objects on input and output, plus, perhaps,
> environmental / credential location information for certain functions.

Agreed.

>  The environmental / credential location information may not be needed
> in some operating systems (because the proxy server will be able to
> use APIs like door_ucred(3DOOR), on Solaris, to find out what it needs
> about the caller), and in any case will need to be either a typed hole
> a an opaque type defined by each OS.

I am not sure I really want to care about OSs that cannot ask the kernel
who's on the other side of a pipe. I would rather let whoever cares
about those to send patches later, they can be as simple as requiring
the creation of multiple sockets with appropriate permissions. After all
if the kernel does not help we cannot make choice of how much trust what
the user is sending us stuff anyway, either we always trust all or
nothing in those cases.

>  - Preferably we should have a set pattern for mapping {argument
> direction, C type} to/from XDR types that can be applied in an
> automated fashion to the GSS C bindings header file(s), thus making it
> possible to avoid having to specify the abstract syntax for the
> protocol.  I believe this is entirely feasible.

Looks like worth putting some effort into this, would keep stuff simpler
and leaner.

>    Of course, for extensibility purposes we need to be careful to use
> wide integer XDR types for any C integer types in the API, and in
> particular we may want to use octet strings for flags arguments, just
> in case we widen any of these in a possible future major version of
> the C bindings (yes, the function names would have to change) and so
> that we don't unnecessarily constrain other language bindings.  (Yes,
> I know that for req_flags, for example, widening the argument has
> knock on effects on the wire for actual mechanisms.  I'm only asking
> that we be as forward-looking as possible in the GSS proxy protocol;
> I'm not proposal actual changes to the API.)
> 
>  - To make it possible to some day consider the "PGSS" or variant
> proposals, we should make the representation of the minor_status
> argument extensible and both, an input and output.

I am not familiar with 'PGSS' care to elaborate if it is really
something we need to care about ?

>  - The protocol probably need not be straight up ONC RPC however,
> though where ONC RPC supports suitable IPC interfaces as transports,
> it'd certainly be worth considering.

We definitely MUST NOT require ONC RPC for the protocol, if someone
wants to use it for something specific and build it on our work I am
quite fine and I do not want to prevent it. But I thikn we do not want
to force all that overhead on Kernels and other implementations by
default as we do not really need it for a local daemon.

>  - New functions should be possible to add at any time.  For ONC RPC
> this would mean we'd need to have at least a registry of procedure
> numbers.  For a non-ONC RPC protocol we could use function name
> strings to name the functions "on the wire", which would then obviate
> the need for a new registry, simplifying the addition of extensions.

If we do not keep a registry we should probably enforce custom
extensions to use a custom name space otherwise we still risk issues
with competing implementation and name collisions.

> I'll probably have more to add later.

Please do, I'd like to get some rough consensus and then quickly proceed
to start the implementation phase.
No I do not want to have roll calls like in IETF here, just a feeling
that people is comfortable and there aren't major obstacles for any of
the stakeholders when we set the direction.

So if you something that you think will cause you pain down the road,
please speak early so we do not have to do painful adjustment later.

I am fully aware that we may still have to do painful adjustments down
the road if we find unforseen obstacles. If we do we will make changes,
the planning phase will not set things in stone like an approved RFC.

I would also like to ask for some volunteers to cover some of the areas
during implementation. We will certainly need at least one kernel
engineer familiar with NFS and gssd to step up and help coding the
changes that may be needed on the kernel side (mostly in the area of
upcall mechanism and upcall protocol handling).

But any help is welcome, I'd like to have a clear idea of what resources
and domain expertise we can count on in order to prioritize the work
that will need to be done and work with people and their schedule to
help make this effort proceed as smoothly as possible.

If you want feel free to call/write to me in private to discuss your
needs and schedule availability.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

