Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59538 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755480Ab0IIBYb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 21:24:31 -0400
Date: Wed, 8 Sep 2010 21:23:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Message-ID: <20100909012340.GA16451@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
 <20100907051336.GC14584@fieldses.org>
 <20100908220528.GD816@fieldses.org>
 <1283987275.2905.50.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1283987275.2905.50.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 08, 2010 at 07:07:55PM -0400, Trond Myklebust wrote:
> On Wed, 2010-09-08 at 18:05 -0400, J. Bruce Fields wrote:
> > On Tue, Sep 07, 2010 at 01:13:36AM -0400, J. Bruce Fields wrote:
> > > After those two patches I can finally pass connectathon tests on 2.6.36.
> > > (Argh.)
> > 
> > Arrrrrrrrgh!
> > 
> > One more: rpc_shutdown_client() is getting called on a client which is
> > corrupt; looking at the client in kgdb:
> > 
> > 0xffff880037fcd2b0: 0x9df20000 0xd490796c 0x65005452 0x0008d144
> > 0xffff880037fcd2c0: 0x42000045 0x0040a275 0x514f1140 0x657aa8c0
> > 0xffff880037fcd2d0: 0x017aa8c0 0x3500b786 0xeac22e00 0x0001f626
> > 0xffff880037fcd2e0: 0x00000100 0x00000000 0x30013001 0x30013001
> > 0xffff880037fcd2f0: 0x2d6e6907 0x72646461 0x70726104 0x0c000061
> > 0xffff880037fcd300: 0x5a5a0100 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd310: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd320: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd330: 0x00000000 0x00000000 0x00000000 0x00000000
> > 0xffff880037fcd340: 0x00000000 0x00000000 0x00000000 0x00000000
> > 0xffff880037fcd350: 0x00000000 0x00000000 0x00000001 0x5a5a5a5a
> > 0xffff880037fcd360: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd370: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd380: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd390: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd3a0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd3b0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd3c0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd3d0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd3e0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd3f0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd400: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd410: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd420: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd430: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd440: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd450: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
> > 0xffff880037fcd460: 0x5a5a5a5a 0x5a5a5a5a
> > 
> > So it's mostly (but not exclusively) POISON_INUSE.  (Which is what the
> > allocator fills an object with before handing back to someone; so
> > apparently someone allocated it but didn't initialize most of it.)
> > 
> > I can't see how the rpc code would return a client that looked like
> > that.  It allocates clients with kzalloc, for one thing.
> > 
> > So all I can think is that we freed the client while it was still
> > in use, and that memory got handed to someone else.
> > 
> > There's only one place in the kernel code that frees rpc clients, in
> > nfsd4_set_callback_client().  It is always called under the global state
> > lock, and does essentially:
> > 
> >         *old = clp->cl_cb_client;
> >         clp->cl_cb_client = new;
> 
> 	flush_workqueue(callback_wq);
> 
> >         if (old)
> >                 rpc_shutdown_client(old);
> > 
> > where "new" is always either NULL or something just returned from rpc_create().
> > 
> > So I don't see any possible way that can call rpc_shutdown_client on the same
> > thing twice.
> 
> A use-after-free rpc call will do just that, since it takes a reference
> to the (freed up) rpc_client and releases it after it is done.
> 
> Any chance you might be doing an rpc call that circumvents the
> callback_wq flush above?

That does seem the more likely source of problems, but the backtrace is

#0  0xffffffff818ee35e in rpc_release_client (clnt=0x5a5a5a5a5a5a5a5a) at net/sunrpc/clnt.c:526

that bogus clnt is cl_parent, so:

#1  0xffffffff818ee739 in rpc_free_client (kref=0xffff880037fcd2b0) at net/sunrpc/clnt.c:479

rpc_clnt was given a pointer to a client that (as above) was already corrupted.

#2  0xffffffff814e0806 in kref_put (kref=0xffff880037fcd2b0, release=0xffffffff818ee6f0 <rpc_free_client>) at lib/kref.c:59
#3  0xffffffff818ee826 in rpc_free_auth (kref=0xffff880037fcd2b0) at net/sunrpc/clnt.c:515
#4  0xffffffff814e0806 in kref_put (kref=0xffff880037fcd2b0, release=0xffffffff818ee7e0 <rpc_free_auth>) at lib/kref.c:59
#5  0xffffffff818ee373 in rpc_release_client (clnt=0xffff880037fcd2b0) at net/sunrpc/clnt.c:528
#6  0xffffffff818ee896 in rpc_shutdown_client (clnt=0xffff880037fcd2b0) at net/sunrpc/clnt.c:460
#7  0xffffffff81276ac5 in nfsd4_set_callback_client (clp=<value optimized out>, new=<value optimized out>) at fs/nfsd/nfs4callback.c:748

And this is the code above.

So it seems to rpc_clnt was already freed before we got here.

I'm stumped for now.  I guess I'll work on finding a reliable reproducer.

--b.

#8  0xffffffff81276c71 in setup_callback_client (clp=0xffff8800329380d8, cb=<value optimized out>) at fs/nfsd/nfs4callback.c:508
#9  0xffffffff81276cf0 in nfsd4_probe_callback (clp=<value optimized out>, cb=<value optimized out>) at fs/nfsd/nfs4callback.c:571
#10 0xffffffff81272969 in nfsd4_setclientid_confirm (rqstp=0xffff88003e5c8000, cstate=<value optimized out>, setclientid_confirm=0xffff880037fe4080) at fs/nfsd/nfs4state.c:1810
#11 0xffffffff81262b51 in nfsd4_proc_compound (rqstp=0xffff88003e5c8000, args=0xffff880037fe4000, resp=0xffff880037fe5000) at fs/nfsd/nfs4proc.c:1092
#12 0xffffffff8124fcce in nfsd_dispatch (rqstp=0xffff88003e5c8000, statp=0xffff88003c97d03c) at fs/nfsd/nfssvc.c:608
#13 0xffffffff818f8d85 in svc_process_common (rqstp=0xffff88003e5c8000, argv=0xffff88003e5c8108, resv=0xffff88003e5c8148) at net/sunrpc/svc.c:1120
#14 0xffffffff818f93f0 in svc_process (rqstp=<value optimized out>) at net/sunrpc/svc.c:1246
#15 0xffffffff81250412 in nfsd (vrqstp=0xffff88003e5c8000) at fs/nfsd/nfssvc.c:535
#16 0xffffffff81059306 in kthread (_create=0xffff88003c939cc8) at kernel/kthread.c:95
#17 0xffffffff810030f4 in ?? () at arch/x86/kernel/entry_64.S:1176
#18 0x0000000000000000 in ?? ()

