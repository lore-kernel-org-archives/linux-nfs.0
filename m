Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:46657 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757994Ab2HQR03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Aug 2012 13:26:29 -0400
Message-ID: <502E7EC3.5030006@msgid.tls.msk.ru>
Date: Fri, 17 Aug 2012 21:26:27 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
References: <1338469169.2420.7.camel@lade.trondhjem.org> <4FC77128.9090206@msgid.tls.msk.ru> <1338471975.7732.5.camel@lade.trondhjem.org> <4FC77755.5060606@msgid.tls.msk.ru> <4FFC2573.8040804@msgid.tls.msk.ru> <20120712125303.GC16822@fieldses.org> <502DA4E8.9050800@msgid.tls.msk.ru> <20120817145616.GC11172@fieldses.org> <20120817160057.GE11172@fieldses.org> <502E7B86.3060702@msgid.tls.msk.ru> <20120817171854.GA14015@fieldses.org>
In-Reply-To: <20120817171854.GA14015@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17.08.2012 21:18, J. Bruce Fields wrote:
> On Fri, Aug 17, 2012 at 09:12:38PM +0400, Michael Tokarev wrote:
[]
>> So we're calling svc_recv in a tight loop, eating
>> all available CPU.  (The above is with just 2 nfsd
>> threads).
>>
>> Something is definitely wrong here.  And it happens mure more
>> often after the mentioned commit (f03d78db65085).
> 
> Oh, neat.  Hm.  That commit doesn't really sound like the cause, then.
> Is that busy-looping reproduceable on kernels before that commit?

Note I bisected this issue to this commit.  I haven't seen it
happening before this commit, and reverting it from 3.0 or 3.2
kernel makes the problem to go away.

I guess it is looping there:


net/sunrpc/svc_xprt.c:svc_recv()
...
        len = 0;
...
        if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
...
        } else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {  <=== here -- has no wspace due to memory...
...  len = <something>
        }

        /* No data, incomplete (TCP) read, or accept() */
        if (len == 0 || len == -EAGAIN)
                goto out;
...
out:
        rqstp->rq_res.len = 0;
        svc_xprt_release(rqstp);
        return -EAGAIN;
}

I'm trying to verify this theory...

/mjt
