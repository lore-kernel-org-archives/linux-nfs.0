Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hapkido.dreamhost.com ([66.33.216.122]:52824 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193Ab1KCDZm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Nov 2011 23:25:42 -0400
Received: from homiemail-a32.g.dreamhost.com (caiajhbdccac.dreamhost.com [208.97.132.202])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 94822195930
	for <linux-nfs@vger.kernel.org>; Wed,  2 Nov 2011 20:25:43 -0700 (PDT)
Received: from homiemail-a32.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a32.g.dreamhost.com (Postfix) with ESMTP id 8B5C1584058
	for <linux-nfs@vger.kernel.org>; Wed,  2 Nov 2011 20:24:59 -0700 (PDT)
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a32.g.dreamhost.com (Postfix) with ESMTPSA id 567E9584057
	for <linux-nfs@vger.kernel.org>; Wed,  2 Nov 2011 20:24:59 -0700 (PDT)
Received: by vws1 with SMTP id 1so520420vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 02 Nov 2011 20:24:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320269170.7734.585.camel@willson.li.ssimo.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
Date: Wed, 2 Nov 2011 22:24:58 -0500
Message-ID: <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>,
        Andy Adamson <andros@netapp.com>, Steve Dickson <steved@redhat.com>,
        Kevin Coffman <kwc@citi.umich.edu>, Bruce Fields <bfields@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>, Greg Hudson <ghudson@mit.edu>,
        Tom Yu <tlyu@mit.edu>, Sam Hartman <hartmans@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Simo,

As you know, I completely agree that we need this.  We have several
implementations, of course (in Linux, in Solaris, probably elsewhere,
such as the BSDs, as well as proprietary ones), but all are -to my
knowledge- focused on providing services to kernel-mode distributed
filesystems (AFS, NFS, Lustre -- all come to mind).  But we need to
generalize this into a service for user-land consumers too, not just
kernel mode consumers.

A few thoughts:

 - XDR is quite fine for this.

 - We want stateless GSS daemons, or mostly stateless at least, for
several reasons:

   a) to protect them against DoS, intentional and not;
   b) to make GSS daemon restart a non-event (OK, this is a much
lesser concern).

   This basically requires credential handle export and
partially-established security context export support.  It also
requires composite name export (to capture name attributes, which
won't be captured by normal exported names).

   Statelessness is not strictly necessary, just highly desirable, so
if this proves difficult (or in some cases credential export turns out
to not possibly be stateless for some mechanisms/credentials), oh
well.  But the *protocol* should be designed to facilitate
statelessness, and certainly not preclude it.

   Note: I really don't want to have an extended sub-thread about
exporting partially-established sec contexts.  We've had that enough
at KITTEN WG, so unless you (whoever wants to bring this up) are
familiar with those threads, please don't bring up the subject, and if
you must, then please use a separate subject.

 - I would like mechglues to support mechanisms being provided by
multiple providers.  This is tricky, and for some mechanisms it will
not be possible to make this perfect, but it's worthwhile  The reason
is this: it should be possible to use a proxy for some credentials and
not a proxy for others (particularly on the initiator side, where a
user may not have direct access to some of their credentials but maybe
can always kinit ones that they do have access to).

   This too is a nice to have rather than a critical feature, but if
we don't have this then we need to make it possible for all GSS apps
to run with just the proxy provider as the one provider (or: the proxy
provider *is* the mechglue as far as the application is concerned).
Otherwise we can get into situations where a library should use the
proxy while another should not, both in the same process, and that
could be obnoxious.

 - Finding credentials, and authorization, will be a bit of a problem.
 How to deal with things like kernel keyrings and KRB5CCNAME-type
environment variables?

   One possibility is that the proxy client passes everything the
proxy server needs to the proxy server.  But that still requires that
the proxy server be able to implement authorization correctly.

   For authorization it will be best to run a proxy for each user or
{user, session} if there's session isolation, or {user, label} for
labeled systems.  This approach helps with finding credentials too.

 - But the more GSS proxy server daemon processes we have, the more we
need to worry about ensuring timely termination.

 - Thus the protocol should look very much like an XDR type for each
GSS function's input arguments and another for each functions output
arguments and return value, plus, for functions dealing in exportable
objects, exported objects on input and output, plus, perhaps,
environmental / credential location information for certain functions.
 The environmental / credential location information may not be needed
in some operating systems (because the proxy server will be able to
use APIs like door_ucred(3DOOR), on Solaris, to find out what it needs
about the caller), and in any case will need to be either a typed hole
a an opaque type defined by each OS.

 - Preferably we should have a set pattern for mapping {argument
direction, C type} to/from XDR types that can be applied in an
automated fashion to the GSS C bindings header file(s), thus making it
possible to avoid having to specify the abstract syntax for the
protocol.  I believe this is entirely feasible.

   Of course, for extensibility purposes we need to be careful to use
wide integer XDR types for any C integer types in the API, and in
particular we may want to use octet strings for flags arguments, just
in case we widen any of these in a possible future major version of
the C bindings (yes, the function names would have to change) and so
that we don't unnecessarily constrain other language bindings.  (Yes,
I know that for req_flags, for example, widening the argument has
knock on effects on the wire for actual mechanisms.  I'm only asking
that we be as forward-looking as possible in the GSS proxy protocol;
I'm not proposal actual changes to the API.)

 - To make it possible to some day consider the "PGSS" or variant
proposals, we should make the representation of the minor_status
argument extensible and both, an input and output.

 - The protocol probably need not be straight up ONC RPC however,
though where ONC RPC supports suitable IPC interfaces as transports,
it'd certainly be worth considering.

 - New functions should be possible to add at any time.  For ONC RPC
this would mean we'd need to have at least a registry of procedure
numbers.  For a non-ONC RPC protocol we could use function name
strings to name the functions "on the wire", which would then obviate
the need for a new registry, simplifying the addition of extensions.

I'll probably have more to add later.

Thanks,

Nico
--
