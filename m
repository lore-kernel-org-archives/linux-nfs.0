From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Non-blocking lock requests during the grace period
Date: Fri, 15 Nov 2002 18:35:16 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15829.12372.977319.366227@helicity.uio.no>
References: <OF92154664.1C5EF07E-ON87256C72.005A0481@us.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OF92154664.1C5EF07E-ON87256C72.005A0481@us.ibm.com>
List-ID: <nfs.lists.sourceforge.net>


     > 2.-I also have this part enclosed in the if(resp->status ==
     > NLM_LCK_DENIED_GRACE_PERIOD) as follows:

     > if(resp->status == NLM_LCK_DENIED_GRACE_PERIOD) {

     >       blah blah...

     > wait_on_grace:
     >                          if ((proc == NLMPROC_LOCK) &&
     >                          !argp->block)
     >                                      return -EAGAIN
     > } else {

     >       ....
     > }

     > This with the intention to be very specific as to when we want
     > the return -EAGAIN to be called.

The above means that you will still block on a F_GETLK query...

In any case, why would we want to return -EAGAIN in one case where
argp->block isn't set, and not in another? If there are cases where we
want to block and where we are not currently setting argp->block (the
only one I can think of might be NLMPROC_UNLOCK), then we should fix
the caller.

Cheers,
  Trond
