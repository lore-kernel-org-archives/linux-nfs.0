From: Olaf Kirch <okir@suse.de>
Subject: Re: [NFS] [PATCH][RFC] use completions instead of sleep_on forrpciod
Date: Tue, 10 Feb 2004 10:15:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210091520.GD20932@suse.de>
References: <20040207144405.GA19416@lst.de> <20040209102801.GC21364@suse.de> <35059.80.213.3.64.1076359739.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com,
        nfs@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: trond.myklebust@fys.uio.no
In-Reply-To: <35059.80.213.3.64.1076359739.squirrel@webmail.uio.no>
Errors-to: netdev-bounce@oss.sgi.com
List-ID: <nfs.lists.sourceforge.net>

On Mon, Feb 09, 2004 at 09:48:59PM +0100, Trond Myklebust wrote:
> > So if you remove the sunrpc BKL be prepared for lots and lots
> > of bug reports :)
> 
> Ahem....
> 
> xprt_alloc_xid is quite safe. It's always called under xprt->xprt_lock.

It wasn't in 2.4.19 or whenever I ran into this. And a per-transport
lock isn't enough to protect a global variable shared by all transports.
Trust me: I spent several weeks debugging this particular problem :)
(See the PS for a somewhat lengthy description of what I remember)

I think that BKL removal at this point is probably not a good idea. Suse
had a BKL removal patch in their SLES8 kernel, and I spent a total of 4-5
weeks hunting down all sorts of bugs related to SMP races. And I don't
think we've seen all of these bugs yet. It might be better to postpone
this for the 2.7 branch.

> The code in unlink.c is only called from dentry_iput() or from
> sillyrename(). In either case, there is no possibility for SMP races.

Are you sure? nfs_dentry_iput explicitly does a lock_kernel before calling
nfs_complete_unlink. I think that's because dentry_iput explicitly drops
the dcache_lock before calling dentry->d_op->d_iput. I wouldn't remove
that BKL :)

And even if you leave that BKL and just remove the one in rpciod, you may
still have a race between rpciod and dput. One CPU may be adding entries
inside nfs_async_unlink (called from dentry_iput()), and at the same
time rpciod can run on another CPU, calling nfs_async_unlink_release,
removing stuff from the nfs_deletes list. The reference counting on
nfs_unlinkdata isn't atomic either.

Olaf

PS: Let me try to put the pieces back together... this was on a PPC
SMP system (so it can take a while for modified values to be
be visible on other CPUs). There were several mounts being stressed
in parallel.

xprt_request_init did a simple "req->rq_xid = xid++;" without any
additional spin locks protecting the xid variable (we have that
spin lock now).

The bug required at least 3 CPUs, and 3 different mounts.

        CPU0            CPU1            CPU2
       --------------------------------------------------------
   |    lock xprt1      lock xprt2
   |                                    lock xprt3
   |    read xid=0
   |                    read xid=0
   |    write xid=1
                                        read xid=1
 time++                                 write xid=2
                        write xid=1
   |                                    unlock xprt3
   |                                    lock xprt3
   |                                    read xid=1
   |                                    write xid=2
   v                                    unlock xprt3

Note that on PPC, modified data can take a long time to become
visible on other CPUs. Cache sync is only guaranteed by operations
such as spin_unlock etc.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 
