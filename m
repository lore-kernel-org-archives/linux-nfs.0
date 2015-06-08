Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:20819 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbbFHRKJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2015 13:10:09 -0400
Date: Mon, 8 Jun 2015 19:10:06 +0200
From: Guillaume Morin <guillaume@morinfr.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Guillaume Morin <guillaume@morinfr.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Subject: Re: [BUG] nfs3 client stops retrying to connect
Message-ID: <20150608171006.GA13396@bender.morinfr.org>
References: <20150521012155.GA19680@bender.morinfr.org>
 <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com>
 <20150604200621.GA10335@bender.morinfr.org>
 <1E6DAEB8-754B-4F88-8301-4A1A9134922A@gmail.com>
 <20150604221404.GA20363@bender.morinfr.org>
 <22109174-5489-46AB-8C0A-62840D63DC97@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <22109174-5489-46AB-8C0A-62840D63DC97@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck,

On 04 Jun 22:57, Chuck Lever wrote:
> > I am 100% sure that XPRT_CONNECTING is the issue because 1) the state
> > had the flag up 2) there was absolutley no nfs network traffic between the
> > client and the server 3) I "unfroze" the mounts by clearing it manually.
> > 
> > xs_tcp_cancel_linger_timeout, I think, is guaranteed to clear the flag.
> 
> I'm speculating based on some comments in the git log, but what if
> the transport never sees TCP_CLOSE, but rather gets an error_report
> callback instead?

I don't think that could be it because xs_tcp_setup_socket() does the
connecting and is clearing the bit in all cases so at the time you would get
a TCP_CLOSE it would have been cleared a while ago.

So that's why I thought the best explanation was finding a place where
the worker task running xs_tcp_setup_socket() is cancelled and the bit
not cleared.  This is how I found xs_tcp_close()

> > Either the callback is canceled and it clears the flag or the callback
> > will do it.  I am not sure how this could leave the flag set but I am
> > not familiar with this code, so I could totally be missing something
> > obvious.
> > 
> > xs_tcp_close() is the only thing I have found which cancels the callback
> > and does not clear the flag.
> 
> How would xs_tcp_close() be invoked?

TBH I do not know.  It's the close() method of the xprt so I am assuming
there are a few places where it could be.  But I am not familiar with
the code base..

> >> It's rather academic, though. All this code was replaced in 4.0.
> > 
> > Well, it's not academic for all the users of the stable branches which
> > might have this bug in the kernel they're running :-)
> 
> I didn't mean to be glib. The point is, stable kernels are always fixed
> by backporting an existing fix from a newer kernel.

The stable kernel rules says an "equivalent" fix in the Linus' tree.  I
think that Greg would pick up this fix unless it's too complicated.

Nevertheless, it's such an annoying bug I am pretty sure the
distributions would pick it up if Greg does not.

We had to move an nfs server on friday and I got a few machines that had
the same issue again... 

Thanks for your help, I appreciate it.

Guillaume.

-- 
Guillaume Morin <guillaume@morinfr.org>
