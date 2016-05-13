Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:60306 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267AbcEMPIv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2016 11:08:51 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Richard Sharpe <realrichardsharpe@gmail.com>
Cc: Steve French <smfrench@gmail.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-afs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        Deepa Dinamani <deepa.kernel@gmail.com>
Subject: Re: [RFC][PATCH 0/6] Enhanced file stat system call
Date: Fri, 13 May 2016 17:08:40 +0200
Message-ID: <2640243.Co6Rj7WIl6@wuerfel>
In-Reply-To: <CACyXjPw-dY4o4O_ZXzeb9R-akmE-r1uAQ7Sd-dGYegkG932yqw@mail.gmail.com>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <4211584.odaTcq8sN6@wuerfel> <CACyXjPw-dY4o4O_ZXzeb9R-akmE-r1uAQ7Sd-dGYegkG932yqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 13 May 2016 07:28:29 Richard Sharpe wrote:
> On Mon, May 9, 2016 at 6:09 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Thursday 05 May 2016 21:00:18 Steve French wrote:
> >> On Thu, May 5, 2016 at 5:54 PM, Steve French <smfrench@gmail.com> wrote:
> >> > On Wed, May 4, 2016 at 8:46 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> >> >> I've discussed this with Deepa in the past, as she is driving the
> >> >> convertion of the inode timestamps to timespec64 now, and we will
> >> >> need a new version of utimensat for her work as well. I can see good
> >> >> reasons either way (allowing updates of btime or disallowing them).
> >> >
> >> It would help interop with Windows (and presumably Mac) if birth time can be
> >> updated
> >
> > Ok, thanks. That is certainly a good reason in favor.
> >
> > If nothing else comes up, I guess we can prepare a patch for a new
> > utimensat variant to do this and wait for more comments on that.

In the meantime I found this LWN article at https://lwn.net/Articles/397442/
Apparently there was a discussion about 6 years ago, without a real
conclusion.

> Isn't there also a strong case for a setattr call that allows us to
> atomically set a collection of attributes from userspace?
> 
> It would seem that network file systems (the clients) could use such features.

I had not heard of this before, but that is obviously another option.
Most of the attributes returned by xstat are read-only, but I guess
this would include uid, gid, {a,b,c,m}time and mode (but not size)
along with a 'valid' mask that decides what to set (as in notify_change),
right?

	Arnd
