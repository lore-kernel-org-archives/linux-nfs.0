From: trond.myklebust@fys.uio.no
Subject: Re: [NFS] [PATCH][RFC] use completions instead of sleep_on
     forrpciod
Date: Mon, 9 Feb 2004 21:48:59 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <35059.80.213.3.64.1076359739.squirrel@webmail.uio.no>
References: <20040207144405.GA19416@lst.de>
    <20040209102801.GC21364@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: netdev@oss.sgi.com, nfs@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Olaf Kirch" <okir@suse.de>, "Christoph Hellwig" <hch@lst.de>
In-Reply-To: <20040209102801.GC21364@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-ID: <nfs.lists.sourceforge.net>

P=E5 m=E5 , 09/02/2004 klokka 11:28, skreiv Olaf Kirch:
> On Sat, Feb 07, 2004 at 03:44:05PM +0100, Christoph Hellwig wrote:
> > The rpciod shutdown code gives ugly sleep_on without BKL warnings in
-mm.  And it looks indeed somewhat racy.
>
> Yes, this code is indeed one of the areas that breaks when you use the
sunrpc code without the BKL. Another one was the missing spinlock in
xprt_alloc_xid. The code in fs/nfs/unlink.c is probably also racy
without BKL.
>
> So if you remove the sunrpc BKL be prepared for lots and lots
> of bug reports :)

Ahem....

xprt_alloc_xid is quite safe. It's always called under xprt->xprt_lock.

The code in unlink.c is only called from dentry_iput() or from
sillyrename(). In either case, there is no possibility for SMP races.

I'll admit that the rpciod killer code is racy, but I'm not sure that
completions are the best answer, as they have at least one nasty feature:
they are not interruptible.

Cheers,
  Trond
