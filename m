Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35669 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932199AbcHORlL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 13:41:11 -0400
Received: by mail-wm0-f41.google.com with SMTP id f65so101011532wmi.0
        for <linux-nfs@vger.kernel.org>; Mon, 15 Aug 2016 10:41:10 -0700 (PDT)
Date: Mon, 15 Aug 2016 19:41:06 +0200
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] src: include cdefs.h for the
 __P() macro
Message-ID: <20160815174106.GJ5822@free.fr>
References: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr>
 <7736F23D-7AA5-4ABD-9693-99C9DCE03B91@oracle.com>
 <20160814221352.GI30771@free.fr>
 <5769F8D5-D7F9-4528-BC5C-B1EF921F52CD@oracle.com>
 <88231b80-c3cd-8486-9e1a-a0abb127a826@RedHat.com>
 <20160815154845.GH5822@free.fr>
 <a64169e9-7e67-b555-1d8f-bf13e1b00a87@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <a64169e9-7e67-b555-1d8f-bf13e1b00a87@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve, All,

Thanks for the feedback! :-)

On 2016-08-15 12:30 -0400, Steve Dickson spake thusly:
> On 08/15/2016 11:48 AM, Yann E. MORIN wrote:
> > On 2016-08-15 11:16 -0400, Steve Dickson spake thusly:
[--SNIP--]
> >> Any idea what could break by removing them??
> > 
> > Virtually nothing. If you look at the glibc code, __P(arg) just expands
> > to its argument arg:
> > 
> >     /* These two macros are not used in glibc anymore.  They are kept here
> >        only because some other projects expect the macros to be defined.  */
> >     #define __P(args)       args
> >     #define __PMT(args)     args
[--SNIP--]
> hmm... it just worries me to remove things from code that
> is this aged ;-) 9 out 10 times something break.

Yes, I understand your position. "If it aint' broke, don't fix it."
But I argue it is broken. ;-)

Just to expand on my position, I did some more research. glibc has
dropped K&R support since 2000 (16 yeas ago!):

    commit 7f4e0e588681d0670c78472f81c21e63bb5772d6
    Author: Ulrich Drepper <drepper@redhat.com>
    Date:   Fri Mar 31 04:17:54 2000 +0000

        Update.

        2000-03-30  Andreas Jaeger  <aj@suse.de>

            * misc/sys/cdefs.h: Remove K&R support.

And since then, __P() has been defined to just expand to its argument.

The current code was commited in 2004, in d19687d6 (which touches a lot
of files, unfortunately, so not reproducing it here...)

So, trying a little thought experiment now. All versions of gcc that we
are supposed to encounter nowadays are ANSI-compliant; they don;t need
__P().

The other compiler worth investigating is clang. I haven't checked, but
I would expect it is ANSI-compliant too.

Just as a joke, tinycc claims to be C99, so ANSI-compliant as well.

We're left with obscur or commercial compilers now. Which one would not
be ANSI-compliant and would still use K&R rules? If that was the case,
they would not be able to build even 1% of the corpus of open source
code available.

And even if such a compiler existed, would we want to support it?

> >>> Post both to the mailing lists and folks here can decide which is
> >>> better.
> >>>
> >>> You might not have time for all that ;-) so you could pick one and
> >>> add a strong technical argument in the patch description why that
> >>> is the best choice.
> >>>
> >>> I think I like 2. overall as it should leave the rpcbind source
> >>> code a little easier to read, no new autoconf logic is needed, and
> >>> there appears to be one distro that is already going that way.
> >> I lean more toward taking the patch as is and failing the
> >> configuration if the header file does not exist.. 
> > 
> > Still the case with the above explanations?
> I do see your points... It still worries me but lets hope
> nothing breaks when they are removed... 

So, does that mean you're OK with a patch to get rid of them (at least
to review it)?

Regards,
Yann E. MORIN.

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
