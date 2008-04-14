From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Mon, 14 Apr 2008 13:19:09 -0400
Message-ID: <20080414171909.GE15950@fieldses.org>
References: <E1JjcgO-0004q2-VJ@pomaz-ex.szeredi.hu> <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org> <20080410215410.GF22324@fieldses.org> <E1JkxZI-0003Bc-9C@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, eshel@almaden.ibm.com, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763090AbYDNRTg@vger.kernel.org>
In-Reply-To: <E1JkxZI-0003Bc-9C@pomaz-ex.szeredi.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 13, 2008 at 10:28:08AM +0200, Miklos Szeredi wrote:
> > Apologies, that was indeed a behavioral change introduced in a commit
> > that claimed just to be shuffling code around.
> 
> Another complaint about this series: using EINPROGRESS to signal
> asynchronous locking looks really fishy.  How does the filesystem
> know, that the caller wants to do async locking?

The caller sets a fl_grant callback.  But I guess the interesting
question is how the caller knows that the filesystem is really going to
return the results asynchronously:

> How do we make sure,
> that the filesystem (like fuse or 9p, which "blindly" return the error
> from the server) doesn't return EINPROGRESS even when it's _not_ doing
> an asynchronous lock?

Right, there's no safeguard there--if fuse returns EINPROGRESS, then
we'll wait for a grant callback that's not going to come.  It should
time out, so that's not a total disaster, but still.

Anyway, I'm not sure what to do about that.

> 
> I think it would have been much cleaner to have a completely separate
> interface for async locking, instead of trying to cram that into
> f_op->lock().

Maybe so.  ->lock() had quite a bit crammed into it even before this.

> Would that be possible to fix now?  Or at least make EINPROGRESS a
> kernel-internal error value (>512), to make it that it has a special
> meaning for the _kernel only_?

Perhaps so.

The behavior of lockd will still depend to some degree on the exact
error returned from the filesystem--e.g. if you return -EAGAIN from
->lock() without later calling ->fl_grant() it will cause some
unexpected delays.  (Though again clients will eventually give up and
poll for the lock.)

--b.
