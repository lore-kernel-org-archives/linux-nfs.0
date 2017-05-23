Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764383AbdEWPMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 11:12:50 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAEk6tEyjk4=rHfsJUZ7dYPpdSa-=QX6QAm8ni8-ySpHmjUMwTg@mail.gmail.com>
References: <CAEk6tEyjk4=rHfsJUZ7dYPpdSa-=QX6QAm8ni8-ySpHmjUMwTg@mail.gmail.com> <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
To: Jessica Frazelle <me@jessfraz.com>
Cc: dhowells@redhat.com, trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2017 16:12:38 +0100
Message-ID: <2812.1495552358@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jessica Frazelle <me@jessfraz.com> wrote:

> Adding a container object seems a bit odd to me because there are so
> many different ways to make containers, aka not all namespaces are
> always used

This is already dealt with to some extent.  It can create/inherit namespaces
like fork - except that you get an extra option (literally, create with no
mount namespace and create that when you provide a root mount).

Modifying the namespace subscriptions is on the to-do list.

> as well as not all cgroups,

cgroups are on the to-do list.

> various LSM objects sometimes apply,

I added a hook for the LSM to use.

> mounts blah blah blah.

You can mount into the container and you can create sockets in the container
from outside the container.

> The OCI spec

This?

	https://github.com/opencontainers/runtime-spec/blob/master/README.md

> was made to cover all these things so why a kernel object?

Because there are some things the kernel doesn't do that it should (upcalling
into the correct namespace junction for example), and some things I've been
asked to add for which there's no clear place to do so.

> I don't exactly see a future where the container runtimes convert to this
> unless it covers all the same mods as the mods in the OCI spec, not saying
> it needs to abide by the spec, just saying it should allow all the same
> things.

I haven't looked at the OCI spec as yet.

Note that this is *not* a replacement for a container application.  I'm not
trying to deprecate Docker or whatever.  It's something for those container
applications to use.

> Which really just seems, imo, like a pain for the kernel to have to
> maintain.

Namespaces are a pain, particularly as lots of things exist in more than one
of the things.

David
