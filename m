From: Juan Gomez <juang@us.ibm.com>
Subject: Re: Non-blocking lock requests during the grace period
Date: Fri, 15 Nov 2002 10:48:49 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <OFFF0C4F23.C5AA44D6-ON87256C72.0066E60D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: trond.myklebust@fys.uio.no
List-ID: <nfs.lists.sourceforge.net>





Guess you are right. I was just worried that this code does not become
active for any other case than the one we were trying to fix.
We should also return when called from test as it should be non-blocking.
Then we do have the problem with UNLOCKs so we
have two choices: either fix the caller or just check for either lock or
test and block. I rather the last one.


Juan




|---------+---------------------------->
|         |           Trond Myklebust  |
|         |           <trond.myklebust@|
|         |           fys.uio.no>      |
|         |                            |
|         |           11/15/02 09:35 AM|
|         |           Please respond to|
|         |           trond.myklebust  |
|         |                            |
|---------+---------------------------->
  >-------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                         |
  |       To:       Juan Gomez/Almaden/IBM@IBMUS                                                                            |
  |       cc:       linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net                                                 |
  |       Subject:  Re: Non-blocking lock requests during the grace period                                                  |
  |                                                                                                                         |
  |                                                                                                                         |
  >-------------------------------------------------------------------------------------------------------------------------|




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
