From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] remove redundant NULL pointer checks prior to calling
	kfree() in fs/nfsd/
Date: Sun, 27 Mar 2005 16:30:19 +0200
Message-ID: <1111933819.6297.45.camel@laptopd505.fenrus.org>
References: <Pine.LNX.4.62.0503252319220.2498@dragon.hyggekrogen.localhost>
	 <Pine.LNX.4.61.0503251731240.6372@chaos.analogic.com>
	 <1111826041.6293.31.camel@laptopd505.fenrus.org>
	 <200503271545.28335.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-os@analogic.com, Jesper Juhl <juhl-lkml@dif.dk>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200503271545.28335.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sun, 2005-03-27 at 15:45 +0300, Denis Vlasenko wrote:
> On Saturday 26 March 2005 10:34, Arjan van de Ven wrote:
> > On Fri, 2005-03-25 at 17:34 -0500, linux-os wrote:
> > > On Fri, 25 Mar 2005, Jesper Juhl wrote:
> > > 
> > > > (please keep me on CC)
> > > >
> > > >
> > > > checking for NULL before calling kfree() is redundant and needlessly
> > > > enlarges the kernel image, let's get rid of those checks.
> > > >
> > > 
> > > Hardly. ORing a value with itself and jumping on condition is
> > > real cheap compared with pushing a value into the stack
> > 
> > which century are you from?
> > "jumping on condition" can easily be 100+ cycles, depending on how
> > effective the branch predictor is. Pushing a value onto the stack otoh
> > is half a cycle.
> 
> linux-os is right because kfree does NULL check with exactly
> the same code sequence, test and branch:

I know it does. The thing is that you have *two* chances to get a branch
mispredict now.

Now if kfree did NOT do the if but move it always to the caller, then
you have somewhat different dynamics (since you then always if the
conditional jump once no matter) but that is not the case.

> I conclude that if(p) kfree(p) makes sense only if:
> a) p is more often NULL than not, and
> b) it's in the hot path (you don't want to save on code size)
> 
> Since (a) is not typical, I think Jesper's cleanups are ok.

note that to gain from teh branch predictor "more often than not"
probably needs to be in the 20:1 ratio to actually gain.
