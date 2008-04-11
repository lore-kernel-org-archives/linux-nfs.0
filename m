From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Fri, 11 Apr 2008 15:19:10 -0400
Message-ID: <20080411191910.GB16965@fieldses.org>
References: <E1JjcgO-0004q2-VJ@pomaz-ex.szeredi.hu> <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org> <20080410215410.GF22324@fieldses.org> <E1JkOff-0000pS-A7@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, eshel@almaden.ibm.com, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JkOff-0000pS-A7@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:12:23PM +0200, Miklos Szeredi wrote:
> > > OK. So the correct fix here should really be applied to fcntl_setlk().
> > > There is absolutely no reason why we should be looping at all if the
> > > filesystem has a ->lock() method.
> > > 
> > > In fact, this looping behaviour was introduced recently in commit
> > > 7723ec9777d9832849b76475b1a21a2872a40d20.
> > 
> > Apologies, that was indeed a behavioral change introduced in a commit
> > that claimed just to be shuffling code around.
> 
> Yeah, that patch looks totally wrong.  It's not generally a good idea
> to do a loop where the exit condition depends on something you don't
> control.  And error values from filesystem methods are typically like
> that.  For example with fuse, the error code could come from an
> unprivileged userspace process.
> 
> I didn't realize this aspect of the bug previously, because I
> concentrated on the lockd inconsistency.
> 
> Btw, why hasn't this work been posted on -fsdevel prior to merging
> into mainline?

http://marc.info/?l=linux-fsdevel&m=117581629326194&w=2

--b.

> 
> > 
> > > Marc, Bruce, why was this
> > > done, and how are filesystems now supposed to behave?
> > > 
> > 
> > The assumption must have been that -EAGAIN could only mean that we
> > needed to keep blocking, and hence was a nonsensical return from a
> > filesystem lock method that waited itself for the lock to become
> > available--such a method would return 0, -EINTR (or some more exotic
> > error), or continue waiting.
> 
> EAGAIN for a blocking lock is nonsensical, so my original patch could
> still make sense.  But that's no longer a regression, and not all that
> important.
