From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] remove redundant NULL pointer checks prior to calling
	kfree() in fs/nfsd/
Date: Sat, 26 Mar 2005 09:34:00 +0100
Message-ID: <1111826041.6293.31.camel@laptopd505.fenrus.org>
References: <Pine.LNX.4.62.0503252319220.2498@dragon.hyggekrogen.localhost>
	 <Pine.LNX.4.61.0503251731240.6372@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesper Juhl <juhl-lkml@dif.dk>, Neil Brown <neilb@cse.unsw.edu.au>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org
To: linux-os@analogic.com
In-Reply-To: <Pine.LNX.4.61.0503251731240.6372@chaos.analogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 2005-03-25 at 17:34 -0500, linux-os wrote:
> On Fri, 25 Mar 2005, Jesper Juhl wrote:
> 
> > (please keep me on CC)
> >
> >
> > checking for NULL before calling kfree() is redundant and needlessly
> > enlarges the kernel image, let's get rid of those checks.
> >
> 
> Hardly. ORing a value with itself and jumping on condition is
> real cheap compared with pushing a value into the stack

which century are you from?
"jumping on condition" can easily be 100+ cycles, depending on how
effective the branch predictor is. Pushing a value onto the stack otoh
is half a cycle. 

Your argument was right probably in 1994, when cpus didn't do
speculation and out of order execution...
