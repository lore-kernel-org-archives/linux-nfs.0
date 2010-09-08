Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab0IHWGS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 18:06:18 -0400
Date: Wed, 8 Sep 2010 18:05:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Message-ID: <20100908220528.GD816@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
 <20100907051336.GC14584@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100907051336.GC14584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 07, 2010 at 01:13:36AM -0400, J. Bruce Fields wrote:
> After those two patches I can finally pass connectathon tests on 2.6.36.
> (Argh.)

Arrrrrrrrgh!

One more: rpc_shutdown_client() is getting called on a client which is
corrupt; looking at the client in kgdb:

0xffff880037fcd2b0: 0x9df20000 0xd490796c 0x65005452 0x0008d144
0xffff880037fcd2c0: 0x42000045 0x0040a275 0x514f1140 0x657aa8c0
0xffff880037fcd2d0: 0x017aa8c0 0x3500b786 0xeac22e00 0x0001f626
0xffff880037fcd2e0: 0x00000100 0x00000000 0x30013001 0x30013001
0xffff880037fcd2f0: 0x2d6e6907 0x72646461 0x70726104 0x0c000061
0xffff880037fcd300: 0x5a5a0100 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd310: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd320: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd330: 0x00000000 0x00000000 0x00000000 0x00000000
0xffff880037fcd340: 0x00000000 0x00000000 0x00000000 0x00000000
0xffff880037fcd350: 0x00000000 0x00000000 0x00000001 0x5a5a5a5a
0xffff880037fcd360: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd370: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd380: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd390: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd3a0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd3b0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd3c0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd3d0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd3e0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd3f0: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd400: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd410: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd420: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd430: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd440: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd450: 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a 0x5a5a5a5a
0xffff880037fcd460: 0x5a5a5a5a 0x5a5a5a5a

So it's mostly (but not exclusively) POISON_INUSE.  (Which is what the
allocator fills an object with before handing back to someone; so
apparently someone allocated it but didn't initialize most of it.)

I can't see how the rpc code would return a client that looked like
that.  It allocates clients with kzalloc, for one thing.

So all I can think is that we freed the client while it was still
in use, and that memory got handed to someone else.

There's only one place in the kernel code that frees rpc clients, in
nfsd4_set_callback_client().  It is always called under the global state
lock, and does essentially:

        *old = clp->cl_cb_client;
        clp->cl_cb_client = new;
        if (old)
                rpc_shutdown_client(old);

where "new" is always either NULL or something just returned from rpc_create().

So I don't see any possible way that can call rpc_shutdown_client on the same
thing twice.

It could be a double-free inside the rpc code somewhere, but I haven't found
any.

This happened during the pynfs DELEG9 test over krb5i, but I can't reproduce it
reliably.

Bah.  Anyone have debugging advice?

--b.
