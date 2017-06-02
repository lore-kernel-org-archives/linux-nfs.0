Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33337 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdFBPr5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jun 2017 11:47:57 -0400
Received: by mail-qk0-f180.google.com with SMTP id y201so62673844qka.0
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jun 2017 08:47:57 -0700 (PDT)
Message-ID: <1496418474.13822.6.camel@redhat.com>
Subject: Re: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service
 request_key upcalls
From: Jeff Layton <jlayton@redhat.com>
To: Colin Walters <walters@verbum.org>,
        David Howells <dhowells@redhat.com>
Cc: James.Bottomley@HansenPartnership.com, ebiederm@xmission.com,
        linux-nfs@vger.kernel.org, containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, keyrings@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Date: Fri, 02 Jun 2017 11:47:54 -0400
In-Reply-To: <1496244979.313075.994296480.7C5735E8@webmail.messagingengine.com>
References: <1496239145.289295.994170312.57409998@webmail.messagingengine.com>
         <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
         <3412.1496242065@warthog.procyon.org.uk>
         <1496244979.313075.994296480.7C5735E8@webmail.messagingengine.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-31 at 11:36 -0400, Colin Walters wrote:
> On Wed, May 31, 2017, at 10:47 AM, David Howells wrote:
> 
> 
> > > So if the mount-in-container is mostly init containers, and for init
> > > containers you have *all* namespaces usually, does it make
> > > sense to have the capability to match namespaces for key services?
> > 
> > Yes.
> > 
> > If I don't provide it, someone will complain that I haven't provided it.
> 
> I don't think it's as clear cut as that.  I'd agree that where possible, it makes
> sense to be general since it's hard to envision every use case, but in this particualr
> case there are risks around security and clear maintenance issues.  Providing
> a feature without *known* users in a security-sensitive context seems to
> me to be something to think twice about.
> 

I agree that it's worth being very careful when we add things that are
security sensitive. But...

It's not just about mounting. Once the fs is mounted, then the kernel
may need to perform an upcall to get a key to authenticate or do some
sort of idmapping. How do we dispatch the upcall in such a way that it
is performed in the correct namespaces? This really matters if you want
to do something like nfs or smb with gssapi auth. We can't sanely do
that in a container today (though it can be made to work for some use
cases).

Ideally we'd like to run the upcall in the same set of namespaces that
the user process initiating the activity is running. This allows us to
do things like get the correct krb5 key to do something on a nfs or
cifs share, or map usernames to the correct uids in network
filesystems.

Right now, we can't really use network filesystems in any sort of
complex configuration properly from containerized processes. It works
just fine until you have to upcall for something, at which point the
whole house of cards falls over.

That's the ultimate problem I'd like to see solved here.

> > > Something that worries me a lot here is for e.g. Docker today, the default
> > > is uid 0 but not CAP_SYS_ADMIN.  We don't want a container that I run
> > > with --host=net to be able to read the "host" keyrings, even if it shares
> > > the host network namespace.
> > 
> > This is a separate issue.
> 
> Kind of - what I'm getting at is that today, changing any of the kernel
> upcalls is a fully privileged operation.  Most container userspace tools
> mount /proc read-only to ensure that even uid 0 containers can't change it
> by default.
> 
> (Wait, is /sbin/request-key really hardcoded in the kernel?  I guess that's
>  good from the perspective of not having containers be able to change it 
>  like they could /proc/sys/kernel/core_pattern if it was writable, but
>  it seems surprising)
> 
> Anyways, if we now expose a method to configure this, we have to look
> at the increase in attack surface.
> 
> In practice again, most container implementations I'm aware of use
> seccomp today to simply block off access to the keyring.   As I mentioned
> Docker does it, so does flatpak:
> https://github.com/flatpak/flatpak/blob/ea7077fcd431fb98fe85cd815cbd2ec13df58d09/common/flatpak-run.c#L4007
> and Chrome:
> https://cs.chromium.org/chromium/src/sandbox/linux/seccomp-bpf-helpers/syscall_sets.cc?q=keyctl&dr=C&l=791
> 
> But I'm a bit uncertain about *relying* on the seccomp filtering.  Particularly
> because we do want the "init container" approach to work and be able
> to use the kernel keyring, but also not be able to affect other containers
> or the host.
> 
> > Keys may be relevant in different namespaces, which makes namespacing them
> > hard to achieve.  For instance, dns-, idmapper- and rxrpc-type keys should
> > probably be differentiated by network namespace.
> > 
> > However, it might be worth creating a keyrings namespace.
> 
> Hm, yes - I think I was conflating CLONE_NEWUSER with uid 0's keyring
> but that's a distinct thing from the kernel keyrings.
> 
> > > Basically my instinct here is to be conservative and have KEYCTL_SERVICE_ADD
> > > require CAP_SYS_ADMIN and only affect the userns keyring.
> > 
> > "Affect" in what sense?
> 
> Operate on at all - view/read/write/search etc.
> 
> At a high level I'm glad you're looking at the "service fd" model instead of
> upcalls - I do think it'll get us to a better place.  The main thing I'm getting
> at first though is making sure we're not introducing new security issues, and that the
> new proposed API makes sense for some of the important userspace use cases.
>

I think I'd rather see a new capability flag for this
(CAP_REGISTER_UPCALL_HANDLER or somesuch). Then you could assign that
to containers that you trust to register a sane handler. CAP_SYS_ADMIN
could include that capability, of course.

-- 
Jeff Layton <jlayton@redhat.com>
