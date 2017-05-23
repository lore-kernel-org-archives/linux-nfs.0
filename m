Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63267 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751746AbdEWPaX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 11:30:23 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1495551292.2742620.985957224.3FCF254A@webmail.messagingengine.com>
References: <1495551292.2742620.985957224.3FCF254A@webmail.messagingengine.com> <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk> <87lgpoww67.fsf@xmission.com> <1495491733.25946.3.camel@redhat.com> <874lwbraxh.fsf@xmission.com> <CAEiveUcbmm5m4=11ZppxAWppeoFWUBFpLC7dAZRuBCTFHR548g@mail.gmail.com>
To: Colin Walters <walters@verbum.org>
Cc: dhowells@redhat.com, Djalal Harouni <tixxdz@gmail.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Jeff Layton <jlayton@redhat.com>, trondmy@primarydata.com,
        Miklos Szeredi <mszeredi@redhat.com>,
        linux-nfs@vger.kernel.org,
        "linux-kernel" <linux-kernel@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2017 16:30:19 +0100
Message-ID: <3118.1495553419@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Colin Walters <walters@verbum.org> wrote:

> Why not drop the upcall model in favor of having userspace monitor events
> via a (more efficient) protocol and react to them on its own?

 (1) That's not necessarily more efficient.  You now have the overhead of a
     permanently running userspace daemon in every relevant namespace
     combination.

 (2) You then have to work out how to route to the appropriate daemon.

> It's just generally more flexible

Actually, it's less flexible.  You can't easily get at the caller's
namespaces.

> and avoids all of those issues like replicating the seccomp configuration,
> etc.

So does my container implementation.

> Something like inotify/signalfd could be a precedent around having a read()/poll()able
> fd.  /proc/keys-requests ?
>
> Then if you create a new user namespace, and open /proc/keys-requests, the
> kernel will always write to that instead of calling /sbin/request-key.

That's not good enough.  You're basically making it one daemon per user
namespace and ignoring all the other namespaces.

[Also note that the kernel would have to paste a temporary authorisation key
 into the daemon's session keyring for each key that requires instantiation].

David
