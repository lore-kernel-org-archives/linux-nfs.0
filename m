From: trond.myklebust@fys.uio.no
Subject: Re: [NFS] [PATCH][RFC] use completions instead of sleep_on
     forrpciod
Date: Tue, 10 Feb 2004 12:47:29 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <33285.80.213.3.64.1076413649.squirrel@webmail.uio.no>
References: <20040207144405.GA19416@lst.de> <20040209102801.GC21364@suse.de>
    <35059.80.213.3.64.1076359739.squirrel@webmail.uio.no>
    <20040210091520.GD20932@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Christoph Hellwig" <hch@lst.de>, netdev@oss.sgi.com,
        nfs@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20040210091520.GD20932@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-ID: <nfs.lists.sourceforge.net>

P=E5 ty , 10/02/2004 klokka 10:15, skreiv Olaf Kirch:
> It wasn't in 2.4.19 or whenever I ran into this. And a per-transport
lock isn't enough to protect a global variable shared by all transports.
Trust me: I spent several weeks debugging this particular problem :)
(See the PS for a somewhat lengthy description of what I remember)

Duh... I forgot that the XID was still global...

Does anybody see any problems with moving the XID counter into the struct
xprt? Please bear in mind that the replay caches on modern NFS servers
look at XID+client IP address+port number, so 2 sockets that play the sam=
e
XID to the server should not normally conflict.

> I think that BKL removal at this point is probably not a good idea. Sus=
e
had a BKL removal patch in their SLES8 kernel, and I spent a total of
4-5
> weeks hunting down all sorts of bugs related to SMP races. And I don't
think we've seen all of these bugs yet. It might be better to postpone
this for the 2.7 branch.

I totally agree with this...

No extra work has been done on BKL removal in the 2.6 branch, and I know
that the old patch that was up for testing in the 2.4 tree was buggy in
several ways...

> > The code in unlink.c is only called from dentry_iput() or from
sillyrename(). In either case, there is no possibility for SMP races.
>
> Are you sure? nfs_dentry_iput explicitly does a lock_kernel before
calling
> nfs_complete_unlink. I think that's because dentry_iput explicitly drop=
s
the dcache_lock before calling dentry->d_op->d_iput. I wouldn't remove
that BKL :)

Yep, but there is only one inode per dentry, and the VFS rules forbids yo=
u
to convert a negative dentry into a positive one (the contrary is allowed=
,
but only under certain restricted situations).

> And even if you leave that BKL and just remove the one in rpciod, you
may
> still have a race between rpciod and dput. One CPU may be adding entrie=
s
inside nfs_async_unlink (called from dentry_iput()), and at the same
time rpciod can run on another CPU, calling nfs_async_unlink_release,
removing stuff from the nfs_deletes list. The reference counting on
nfs_unlinkdata isn't atomic either.

Sure... The unlink.c global lists definitely depend on the BKL for
protection. The latter would need to be replaced by a new global
spinlock.

Cheers,
  Trond
