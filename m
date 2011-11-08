Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753220Ab1KHLc3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Nov 2011 06:32:29 -0500
Date: Tue, 8 Nov 2011 06:32:18 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Hamo <hamo.by@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        steved@redhat.com
Subject: Re: [PATCH] mount.nfs: ensure AF priority when mounting
Message-ID: <20111108063218.27cc43aa@tlielax.poochiereds.net>
In-Reply-To: <CAO_0yfM4ozPUCw0qvxrA3Z18cJaq9WiEZgWNhrf8wLee8baT8g@mail.gmail.com>
References: <CAO_0yfP8XRH0+Gdn43QSncUFFPPmwbsxx2ZFdPpFTjKAQeuyAw@mail.gmail.com>
	<4A9C7673-1CC1-4B8E-AF18-4DA39A14BCB7@oracle.com>
	<CAO_0yfM4ozPUCw0qvxrA3Z18cJaq9WiEZgWNhrf8wLee8baT8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Nov 2011 12:51:21 +0800
Hamo <hamo.by@gmail.com> wrote:

> On Tue, Nov 8, 2011 at 11:57 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> > On Nov 7, 2011, at 10:14 PM, Hamo wrote:
> >
> >> On different architectures, getaddrinfo() may return different
> >> orders of address families. This may confuse the users.
> >
> > Isn't this controlled by /etc/gai.conf ?  I'm not sure we want mount.nfs to override that.
> >
> 
> After digging into this file, I found the order can be controlled by
> this file, but without it, the order is not predictable.
> Should we first try IPv6 then IPv4? This sounds reasonable.
> So now, I am also not sure should we override this. Waiting for the
> opinions from others.


I don't think we ought to try and do this in nfs-utils. I see no reason
that the architecture should have any effect at all on the sort order of
address families being returned. If there is, then that sounds like a
(libc?) bug on those arches.

-- 
Jeff Layton <jlayton@redhat.com>
