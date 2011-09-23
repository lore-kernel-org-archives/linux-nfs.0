Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47566 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab1IWH0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 03:26:06 -0400
Received: by bkbzt4 with SMTP id zt4so3218161bkb.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 00:26:04 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeff Layton <jlayton@redhat.com>, Ian Kent <raven@themaw.net>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
	<1316707443.3346.44.camel@perseus.themaw.net>
	<CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
	<1316709935.3346.48.camel@perseus.themaw.net>
	<20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
	<20110922144453.6cf53a25@barsoom.rdu.redhat.com>
	<1316719228.3968.14.camel@lade.trondhjem.org>
	<CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
	<CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
	<1316740873.9186.19.camel@lade.trondhjem.org>
Date: Fri, 23 Sep 2011 09:25:34 +0200
In-Reply-To: <1316740873.9186.19.camel@lade.trondhjem.org> (Trond Myklebust's
	message of "Thu, 22 Sep 2011 21:21:13 -0400")
Message-ID: <878vpfvhxt.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust <Trond.Myklebust@netapp.com> writes:

> On Thu, 2011-09-22 at 18:04 -0700, Linus Torvalds wrote: 
>> On Thu, Sep 22, 2011 at 5:56 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> >
>> > Your assumption is that in the majority of cases, we do _not_ want to
>> > automount the final directory unless we know that we are expecting a
>> > directory.
>> 
>> Umm. That is the assumption yes, BUT THAT IS ALSO THE CURRENT STATE.
>> 
>> So it's more than an assumption. It's a fact.
>> 
>> So when you call it "assumption", you are basically ignoring and
>> trying to belittle current reality. Why?
>
> AFAICR, the whole point of doing the ->automount() stuff was to fix what
> was perceived to be a broken situation in which the application was more
> often than not seeing the properties of a directory which it would
> _never_ directly access.

We are pitting one set of applications against another.  There's no
Right(TM) behavior here.  In any case there will be applications which
will behave strangely, be extremely slow, etc...

Changing the behavior of stat will cause regressions.  Period.  If we
just fixed up those apps which behave badly with the old kernels, there
wouldn't be any regressions.

> David, Ian, Al and I carefully listed the cases where we might want to
> optimise away the automount, and designed a system that fit those cases.
>
> I fully accept that we need to address any regressions that may have
> introduced, but your fix goes beyond the regressions that were reported:
> it basically puts us back where we were before the automount changes. In
> that situation, what have we gained by the changes, and why keep them at
> all?

You are blowing this out of proportion.  Those patches do a lot more
than change the behavior of stat, etc.  The fact that stat will trigger
an automount is only mentioned in passing, and even there it's not
stated that the behavior was actually *changed* from the old autofs4
implentation:

   "I've also extracted the mount/don't-mount logic from autofs4 and
    included it here.  It makes the mount go ahead anyway if someone
    calls open() or creat(), tries to traverse the directory, tries to
    chdir/chroot/etc. into the directory, or sticks a '/' on the end of
    the pathname.  If they do a stat(), however, they'll only trigger
    the automount if they didn't also say O_NOFOLLOW."

Thanks,
Miklos
