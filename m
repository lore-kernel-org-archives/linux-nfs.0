Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45782 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655Ab3JBM6l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 08:58:41 -0400
Date: Wed, 2 Oct 2013 14:58:37 +0200
From: Jan Kara <jack@suse.cz>
To: Zach Brown <zab@redhat.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Ric Wheeler <rwheeler@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20131002125837.GA32181@quack.suse.cz>
References: <20130927205013.GZ30372@lenny.home.zabbo.net>
 <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
 <52474839.2080201@redhat.com>
 <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
 <20130930143432.GG16579@fieldses.org>
 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
 <52499026.3090802@redhat.com>
 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
 <20131001195817.GE10831@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131001195817.GE10831@lenny.home.zabbo.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 01-10-13 12:58:17, Zach Brown wrote:
> > - app calls splice(from, 0, to, 0, SIZE_MAX)
> >  1) VFS calls ->direct_splice(from, 0,  to, 0, SIZE_MAX)
> >     1.a) fs reflinks the whole file in a jiffy and returns the size of the file
> >     1 b) fs does copy offload of, say, 64MB and returns 64M
> >  2) VFS does page copy of, say, 1MB and returns 1MB
> > - app calls splice(from, X, to, X, SIZE_MAX) where X is the new offset
> 
> (It's not SIZE_MAX.  It's MAX_RW_COUNT.  INT_MAX with some
> PAGE_CACHE_SIZE rounding noise.  For fear of weird corners of fs code
> paths that still use int, one assumes.)
> 
> > The point is: the app is always doing the same (incrementing offset
> > with the return value from splice) and the kernel can decide what is
> > the best size it can service within a single uninterruptible syscall.
> > 
> > Wouldn't that work?
> 
> It seems like it should, if people are willing to allow splice() to
> return partial counts.  Quite a lot of IO syscalls technically do return
> partial counts today if you try to write > MAX_RW_COUNT :).
  Yes. Also POSIX says that application must handle such case for read &
write. But in practice programmers are lazy.

> But returning partial counts on the order of a handful of megs that the
> file systems make up as the point of diminishing returns is another
> thing entirely.  I can imagine people being anxious about that.
> 
> I guess we'll find out! 
  Return 4 KB once in a while to screw up buggy applications from the
start :-p

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
