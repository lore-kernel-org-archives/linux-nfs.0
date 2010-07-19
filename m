Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57362 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750740Ab0GSQvx convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 12:51:53 -0400
In-Reply-To: <10783.1279556132@redhat.com>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<AANLkTikuzYqYpGHcubb7QVciZW0dNFjOG82qIwy5M4gO@mail.gmail.com>
	<10783.1279556132@redhat.com>
Date: Mon, 19 Jul 2010 09:51:13 -0700
Message-ID: <AANLkTinVns77R7yCCh-lydd0eQufdAF9O2OaWmCL7uSn@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
From: Linus Torvalds <torvalds@linux-foundation.org>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jul 19, 2010 at 9:15 AM, David Howells <dhowells@redhat.com> wrote:
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>>  - that whole xstat buffer handling is just a mess. I think you
>> already fixed the "xstat_parameters" crud and just made it a simple
>> unsigned long and a direct argument,
>
> I was thinking more of an unsigned int argument, since it can't have more than
> 32 flags in it if it is also to work on 32-bit arches.

That's fine.

>> but the "buffer+buflen" thing is still disgusting.
>>
>>    Why not just leave a few empty fields at the end, and make the rule
>> be: "We don't just add random crap, so don't expect it to grow widely
>> in the future".
>
> Because it gets allocated on the kernel stack.  It's already 160 bytes, and
> expanding it will eat more kernel stack space.  Now, I can offset that by: (a)
> embedding it in struct kstat so that we allocate less stack space in xstat()
> overall, and (b) allocating kstat/xstat structs with kmalloc() rather than on
> the stack in all the stat syscalls.

Using implementation issues like that as a reason for some odd
interface that we'll have to live with for the next decades sounds
bad. It's basically a broken form of versioning, since if you end up
using buffer sizes, everybody will just use "sizeof()" except for some
random crazy developer that decides to re-use a buffer they use for
something else, and then use the size of that instead.

End result: the kernel gets passed in some random constant that
depends on just which version of glibc they were compiled against _or_
on just how crazy they were. And it all just encourages people to do
odd things. For example, the glibc developers, who love adding their
own random fields for crazy "forwards compatibility", will start
extending the xstat structure on their own and then just pass in the
larger size and emulate a few new fields à la that whole vfstat thing.
And then if/when we want to extend on it, we're screwed.

So making it fixed is not only simpler, it avoids all the "I'm passing
in random integers" crud.

You don't need to allocate the whole thing inside the kernel anyway.
Quite the reverse. You probably want to continue using the kernel
"kstat" interface with some extensions. That's the point of kstat,
after all - allowing the filesystem interfaces to share _one_
interface rather than having new interfaces at the VFS level for every
damn new stat implementation we have to do for user space.

In short, your stack space usage is all totally bogus. You should copy
the kstat to the user xstat one field at a time, and NOT allocate an
xstat on the kernel stack at all. There is no advantage to using
"memcpy_to_user()" (after having filled in the kernel struct one field
at a time) over just filling in the user struct directly.

Just do "access_ok() + several __put_user() calls", in other words.

I think you wanted to use "memcpy_to_user()" just because you had that
broken "bufsize" argument to begin with. If you get rid of the
bufsize, you also get rid of the potential for partial structures, and
all the reasons to use memcpy go away.

Just do the obvious thing.

>>  - you use "long long" all over the place. Don't do that. If you want
>> a fixed size, say so, and use "u64/s64". That's the _real_ fixed size,
>> and "long long" just _happens_ to be the same size on all current
>> architectures.
>
> I was following struct stat/stat64 in arch/x86/include/asm/stat.h which do the
> same.  Also, if this is going to be seen by userspace, isn't it better to use
> uint32_t and suchlike?

The arch/x86/include/asm stuff isn't trying to be the same image on
different architectures, it's just x86[-64]-specific. But if you want
to have a cross-architectural thing, you want to use
cross-architectural types. Don't use "long long".

Yeah, we may well do it somewhere, but there's no reason to add new ones.

Another thing you should look for in things like this - make sure that
u64 is always naturally aligned. Otherwise some architectures will
align it at 4-byte boundaries (notably x86-32), while others will
align it at 8-byte boundaries (native 64-bit).

>>  - why create that new kind of xstat() that realistically absolutely
>> nobody will use outside of some very special cases, and that has no
>> real advantages for 99.9% of all people?
>
> The new information is useful for some cases.  Samba for example.  At least
> two of the fields I'm adding are also made available through BSD's stat()
> call, and will automatically be used for some things by autoconf magic if they
> become available.

.. that' a pointless argument. If the only way something gets used is
through autoconf, then clearly nobody cares. Yeah, maybe it adds a
flag to "ls", but let's face is - that isn't actually _buying_
anything.

So the only thing that matters for new system calls is who actually
really seriously wants to use the information, even if it's not there
by default. Is it _anybody_ else than samba?

That's why I asked about maybe making it "open+stat". Because that at
least _potentially_ opens things up to another class of users.

Because if it really is just samba that wants some odd crap that not
even all filesystems support, then why add a whole new xstat for it?
If nobody else clamors for it (except for people who just want new
interfaces), then it's not generic enough to be worth something like
that.

In other words, in the absense of some seriously generic users, it
sounds more like an ioctl to me to ask for something like "creation
time" or "inode version", when not all filesystems support anything
like that.

>> [open+stat}
>
> Which would be used by even fewer people, I suspect.

Umm, no. It would be used by _at_least_ as many people.

And don't get me wrong - I'm not saying "you need to make it
open+stat". I'm saying "you need to make the case that the thing is so
generically useful that it's worth a whole new system call, rather
than just a filesystem specific ioctl".

> Also, I'm not sure how much use the atomicity is, given that the file may have
> changed state between the gathering of the stat data and userspace getting to
> do anything with it.

It's a security issue. It's not atomic wrt the file being edited, but
it would be atomic wrt the filename changing. IOW, the same thing as
why web servers etc need to do "open+fstat" rather than "stat+open".

And yes, we can already do open+fstat. But exactly because it's a
fairly common pattern, and the kinds of programs that do it tend to
also care about performance, maybe they'd like a single system call.

Ask your samba people, for example, if they'd _ever_ do just a
"xstat()"? Somehow I suspect that most server kind of apps almost
always end up doing open+fstat, just because they don't want just the
stat information, and need to do the fstat in order to guarantee they
are talking about the same file.

But again - the whole "open+stat" is not because I think they need to
be done together. It's because I'm trying to see if it could make the
system call worth it at all.

>> >        ssize_t ret = fxstat(unsigned fd,
>>
>> Quite frankly, my gut feel is that once you do "xstat(dfd, filename,
>> ...)" then it's damn stupid to do a separate "fxstat()", when you
>> might as well say that "xtstat(dfd, NULL, ...)" is the same as
>> "fxstat(fd, ...)"
>
> This has been suggested and denounced as stupid already.  That said, I agree
> with you.

Hey, whoever denounced it as stupid obviously doesn't have the neurons
to go around to be involved in the discussion. Ignore them.

                Linus
