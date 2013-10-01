Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209Ab3JAT64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 15:58:56 -0400
Date: Tue, 1 Oct 2013 12:58:17 -0700
From: Zach Brown <zab@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Ric Wheeler <rwheeler@redhat.com>,
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
Message-ID: <20131001195817.GE10831@lenny.home.zabbo.net>
References: <20130927200550.GA22640@fieldses.org>
 <20130927205013.GZ30372@lenny.home.zabbo.net>
 <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
 <52474839.2080201@redhat.com>
 <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
 <20130930143432.GG16579@fieldses.org>
 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
 <52499026.3090802@redhat.com>
 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> - app calls splice(from, 0, to, 0, SIZE_MAX)
>  1) VFS calls ->direct_splice(from, 0,  to, 0, SIZE_MAX)
>     1.a) fs reflinks the whole file in a jiffy and returns the size of the file
>     1 b) fs does copy offload of, say, 64MB and returns 64M
>  2) VFS does page copy of, say, 1MB and returns 1MB
> - app calls splice(from, X, to, X, SIZE_MAX) where X is the new offset

(It's not SIZE_MAX.  It's MAX_RW_COUNT.  INT_MAX with some
PAGE_CACHE_SIZE rounding noise.  For fear of weird corners of fs code
paths that still use int, one assumes.)

> The point is: the app is always doing the same (incrementing offset
> with the return value from splice) and the kernel can decide what is
> the best size it can service within a single uninterruptible syscall.
> 
> Wouldn't that work?

It seems like it should, if people are willing to allow splice() to
return partial counts.  Quite a lot of IO syscalls technically do return
partial counts today if you try to write > MAX_RW_COUNT :).

But returning partial counts on the order of a handful of megs that the
file systems make up as the point of diminishing returns is another
thing entirely.  I can imagine people being anxious about that.

I guess we'll find out! 

- z
