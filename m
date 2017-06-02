Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdFBQeR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Jun 2017 12:34:17 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1496244979.313075.994296480.7C5735E8@webmail.messagingengine.com>
References: <1496244979.313075.994296480.7C5735E8@webmail.messagingengine.com> <1496239145.289295.994170312.57409998@webmail.messagingengine.com> <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk> <3412.1496242065@warthog.procyon.org.uk>
To: Colin Walters <walters@verbum.org>
Cc: dhowells@redhat.com, James.Bottomley@HansenPartnership.com,
        ebiederm@xmission.com, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, keyrings@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Subject: Re: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service request_key upcalls
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 02 Jun 2017 17:34:14 +0100
Message-ID: <2137.1496421254@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Colin Walters <walters@verbum.org> wrote:

> Providing a feature without *known* users in a security-sensitive context
> seems to me to be something to think twice about.

Ummm...  Kernel DNS lookups, NFS idmapper upcalls.  CIFS could use it too.

> Kind of - what I'm getting at is that today, changing any of the kernel
> upcalls is a fully privileged operation.

Yes.  Upcalls are more secure but finding out the collection of namespaces in
which to run an upcall is a real pain - and Eric's 'concrete' method doesn't
actually work.

> (Wait, is /sbin/request-key really hardcoded in the kernel?  I guess that's
>  good from the perspective of not having containers be able to change it 
>  like they could /proc/sys/kernel/core_pattern if it was writable, but
>  it seems surprising)

Namespaces didn't exist at the time.

> Anyways, if we now expose a method to configure this, we have to look
> at the increase in attack surface.

To quote:

> In practice again, most container implementations I'm aware of use
> seccomp today to simply block off access to the keyring.

We're going to have to deal with that, but it's going to take some support on
the kernel side.  I think it may require a 'key' namespace - but that's going
to have potentially difficult interactions with the 'net' namespace for
network filesystems where your process's key and net namespaces are different
to the that of the superblock you're trying to access.

> > > Basically my instinct here is to be conservative and have
> > > KEYCTL_SERVICE_ADD require CAP_SYS_ADMIN and only affect the userns
> > > keyring.

Sorry, what 'userns' keyring?

> At a high level I'm glad you're looking at the "service fd" model instead of
> upcalls - I do think it'll get us to a better place.

I disagree, but it may be the only way, given the unholy mess in which the
Linux 'container' system works.

David

