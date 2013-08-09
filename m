Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcaid.dreamhost.com ([208.97.132.83]:46912 "EHLO
	homiemail-a77.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934385Ab3HIQYe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:24:34 -0400
MIME-Version: 1.0
In-Reply-To: <16961.1375973205@warthog.procyon.org.uk>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	<20130801173854.28023.82045.stgit@warthog.procyon.org.uk>
	<CAK3OfOj6E_thwgwdZUDXrr_7XW4xJkzwxdGU6gKcEJ3twOsm=A@mail.gmail.com>
	<16961.1375973205@warthog.procyon.org.uk>
Date: Fri, 9 Aug 2013 11:24:29 -0500
Message-ID: <CAK3OfOgUbQO+5dKXVEn1e70Y959-GKV9sZxV32Yy6ZSPr=x7Sg@mail.gmail.com>
Subject: Re: [PATCH 1/2] KEYS: Implement a big key type that can save to tmpfs
From: Nico Williams <nico@cryptonector.com>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org, simo@redhat.com,
        linux-kernel@vger.kernel.org, krbdev@mit.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 8, 2013 at 9:46 AM, David Howells <dhowells@redhat.com> wrote:
> Nico Williams <nico@cryptonector.com> wrote:
>
>> b) how to create tmpfs locations in which to store credentials (which
>> can be unbounded in size, so storing them in the kernel is silly;
>
> Ummm...  tmpfs stores them in the kernel too - though it can page them out to
> swap.

Any filesystem uses kernel, doesn't it?  Notionally, however, they
don't.  And notionally tmpfs is not about using memory but about being
non-persistent.  This is important because tmpfs *is* subject to
swapping and that does create security problems (you should want to
encrypt swap).

There's a difference between "notionally not persistent across
reboots" and "notionally stored in the kernel's address space".  The
real question is: why do you want the latter?

Some people have argued (not in this thread, and not recently on this
list) that credentials should be stored in the kernel and not leave it
(i.e., you shouldn't be able to extract them from the kernel).  This
implies a number of things, but one of those is a bad thing: unbounded
kernel credential caches OR LRU/LFU cache eviction.  Some of us rely
on caching to keep latency predictable, so cache eviction could be a
bit rough.  Unbounded kernel credential caches not subject to paging
are a DoS.  Unbounded-but-paged cred caches would be fine, but really,
what's the difference vis-a-vis FILE ccaches in /tmp?  The answer
depends on whether you allow the creds to leave kernel space.

That brings us to: what do we really want?  If we really want users to
not be able to see their tickets' session keys, then we don't need to
store their tickets in kernel land and we don't need to put
krb5_mk_req*() in the kernel either: we need only *wrap* the keys to
that low-level crypto use of those keys happens in the kernel and the
only thing the kernel stores is the wrapping key.  You might even have
a TPM or similar crypto decelerator handle this.

ISTM that a new ccache type whose purpose is to defeat the tmpfs race
conditions of the FILE ccache is a good thing.  I would prefer it to
be *portable*, and it could be, but keyring stuff isn't.  And FILE
ccache remains the lowest common denominator, so there's that too.
And since I've been dealing with some FILE ccache race conditions (see
new thread I'll start next), I think a) I hate FILE ccaches, b) I
don't see how to avoid having them.

> I have altered my big-key implementation to just store small items in an
> internal buffer and big items in a tmpfs file.  This means that small items
> will use up _less_ kernel memory if they're in a key because they won't require
> the overhead of a dentry struct and an inode struct.

Please make sure to have a cache eviction policy...  I don't know what
is "small" when it comes to Kerberos credentials either.  If the
difference between small and large is "lacks / has PAC and/or CAMMAC"
then you'll find that this difference mostly depends on the
environment, and generally your items will be either all "small" or
all large.  Are you building dead code?

>> (b) can be solved in many ways, and the simplest is to have a
>> filesystem where top-level directories named after UIDs "exist" as
>> soon as they are referenced and as long as they are non-empty.  You
>> can use autofs + tmpfs, or a variant of tmpfs for this.
>
> Don't forget to add user namespaces into the mix :-/

Sure; why the ambivalence smiley?

Nico
--
