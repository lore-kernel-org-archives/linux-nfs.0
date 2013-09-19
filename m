Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307Ab3ISNJM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 09:09:12 -0400
Date: Thu, 19 Sep 2013 08:59:24 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Eric Wong <normalperson@yhbt.net>
Cc: Zach Brown <zab@redhat.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130919085924.09b2a25c@tlielax.poochiereds.net>
In-Reply-To: <20130911211722.GA9725@dcvr.yhbt.net>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
	<20130911211722.GA9725@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Sep 2013 21:17:23 +0000
Eric Wong <normalperson@yhbt.net> wrote:

> Zach Brown <zab@redhat.com> wrote:
> > Towards the end of that thread Eric Wong asked why we didn't just
> > extend splice.  I immediately replied with some dumb dismissive
> > answer.  Once I sat down and looked at it, though, it does make a
> > lot of sense.  So good job, Eric.  +10 Dummie points for me.
> 
> Thanks for revisiting that :>
> 
> > Some things to talk about:
> > - I really don't care about the naming here.  If you do, holler.
> 
> Exposing "DIRECT" to userspace now might confuse users into expecting
> O_DIRECT behavior.  I say this as an easily-confused user.
> 
> In the future, perhaps O_DIRECT behavior can become per-splice (instead
> of just per-open) and can save SPLICE_F_DIRECT for that.
> 
> > - We might want different flags for file-to-file splicing and acceleration
> > - We might want flags to require or forbid acceleration
> 

Do we need new flags at all? If both fds refer to files, then perhaps
we can just take it that SPLICE_F_DIRECT behavior is implied?

I'd probably suggest that we not add any more flags than are necessary
until use-cases for them become clear.

> > - We might want to provide all these flags to sendfile, too
> 
> Another syscall?  I prefer not.  Better to just maintain the sendfile
> API as-is for compatibility reasons and nudge users towards splice.
> 

Agreed.

> > Thoughts?  Objections?
> 
> I'll try to test/comment more in a week or two (not much time for
> computing until then).

On the whole, the concept looks sound.

I'll note too that by simply lifting the restriction that one of the
fd's to splice must always be a pipe, that may also give us a relatively
simple way to add recvfile() as well, even if only as a macro wrapper
around splice(). That's been a long sought-after feature of the samba
developers...

Just allow userland to do a splice straight from a socket fd to a file.
We may end up having to copy data if the alignment isn't right, but it'd
still be valuable to do that directly in the kernel in a single syscall.

-- 
Jeff Layton <jlayton@redhat.com>
