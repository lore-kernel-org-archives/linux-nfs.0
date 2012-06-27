Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755986Ab2F0T2R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 15:28:17 -0400
Date: Wed, 27 Jun 2012 15:28:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Harshula <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpciod process is blocked in nfs_release_page waiting for
 nfs_commit_inode to complete
Message-ID: <20120627152814.4774048b@tlielax.poochiereds.net>
In-Reply-To: <1340822635.2398.7.camel@lade.trondhjem.org>
References: <1339764850.30233.11.camel@serendib>
	<20120615092103.15cc2b11@corrin.poochiereds.net>
	<1339795503.16363.9.camel@lade.trondhjem.org>
	<20120627115447.0fdf8c6e@corrin.poochiereds.net>
	<1340822635.2398.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 27 Jun 2012 18:43:56 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-06-27 at 11:54 -0400, Jeff Layton wrote:
> > On Fri, 15 Jun 2012 21:25:10 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Fri, 2012-06-15 at 09:21 -0400, Jeff Layton wrote:
> > > > On Fri, 15 Jun 2012 22:54:10 +1000
> > > > Harshula <harshula@redhat.com> wrote:
> > > > 
> > > > > Hi All,
> > > > > 
> > > > > Can I please get your feedback on the following?
> > > > > 
> > > > > rpciod is blocked:
> > > > > ------------------------------------------------------------
> > > > > crash> bt  2507 
> > > > > PID: 2507   TASK: ffff88103691ab40  CPU: 14  COMMAND: "rpciod/14"
> > > > >  #0 [ffff8810343bf2f0] schedule at ffffffff814dabd9
> > > > >  #1 [ffff8810343bf3b8] nfs_wait_bit_killable at ffffffffa038fc04 [nfs]
> > > > >  #2 [ffff8810343bf3c8] __wait_on_bit at ffffffff814dbc2f
> > > > >  #3 [ffff8810343bf418] out_of_line_wait_on_bit at ffffffff814dbcd8
> > > > >  #4 [ffff8810343bf488] nfs_commit_inode at ffffffffa039e0c1 [nfs]
> > > > >  #5 [ffff8810343bf4f8] nfs_release_page at ffffffffa038bef6 [nfs]
> > > > >  #6 [ffff8810343bf528] try_to_release_page at ffffffff8110c670
> > > > >  #7 [ffff8810343bf538] shrink_page_list.clone.0 at ffffffff81126271
> > > > >  #8 [ffff8810343bf668] shrink_inactive_list at ffffffff81126638
> > > > >  #9 [ffff8810343bf818] shrink_zone at ffffffff8112788f
> > > > > #10 [ffff8810343bf8c8] do_try_to_free_pages at ffffffff81127b1e
> > > > > #11 [ffff8810343bf958] try_to_free_pages at ffffffff8112812f
> > > > > #12 [ffff8810343bfa08] __alloc_pages_nodemask at ffffffff8111fdad
> > > > > #13 [ffff8810343bfb28] kmem_getpages at ffffffff81159942
> > > > > #14 [ffff8810343bfb58] fallback_alloc at ffffffff8115a55a
> > > > > #15 [ffff8810343bfbd8] ____cache_alloc_node at ffffffff8115a2d9
> > > > > #16 [ffff8810343bfc38] kmem_cache_alloc at ffffffff8115b09b
> > > > > #17 [ffff8810343bfc78] sk_prot_alloc at ffffffff81411808
> > > > > #18 [ffff8810343bfcb8] sk_alloc at ffffffff8141197c
> > > > > #19 [ffff8810343bfce8] inet_create at ffffffff81483ba6
> > > > > #20 [ffff8810343bfd38] __sock_create at ffffffff8140b4a7
> > > > > #21 [ffff8810343bfd98] xs_create_sock at ffffffffa01f649b [sunrpc]
> > > > > #22 [ffff8810343bfdd8] xs_tcp_setup_socket at ffffffffa01f6965 [sunrpc]
> > > > > #23 [ffff8810343bfe38] worker_thread at ffffffff810887d0
> > > > > #24 [ffff8810343bfee8] kthread at ffffffff8108dd96
> > > > > #25 [ffff8810343bff48] kernel_thread at ffffffff8100c1ca
> > > > > ------------------------------------------------------------
> > > > > 
> > > > > nfs_release_page() gives kswapd process an exemption from being blocked.
> > > > > Should we do the same for rpciod. Otherwise rpciod could end up in a
> > > > > deadlock where it can not continue without freeing memory that will only
> > > > > become available when rpciod does its work:
> > > > > ------------------------------------------------------------
> > > > > 479 /*
> > > > > 480  * Attempt to release the private state associated with a page
> > > > > 481  * - Called if either PG_private or PG_fscache is set on the page
> > > > > 482  * - Caller holds page lock
> > > > > 483  * - Return true (may release page) or false (may not)
> > > > > 484  */
> > > > > 485 static int nfs_release_page(struct page *page, gfp_t gfp)
> > > > > 486 {   
> > > > > 487         struct address_space *mapping = page->mapping;
> > > > > 488     
> > > > > 489         dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
> > > > > 490     
> > > > > 491         /* Only do I/O if gfp is a superset of GFP_KERNEL */
> > > > > 492         if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
> > > > > 493                 int how = FLUSH_SYNC;
> > > > > 494             
> > > > > 495                 /* Don't let kswapd deadlock waiting for OOM RPC calls */
> > > > > 496                 if (current_is_kswapd())
> > > > > 497                         how = 0;
> > > > > 498                 nfs_commit_inode(mapping->host, how);
> > > > > 499         }
> > > > > 500         /* If PagePrivate() is set, then the page is not freeable */
> > > > > 501         if (PagePrivate(page))
> > > > > 502                 return 0;
> > > > > 503         return nfs_fscache_release_page(page, gfp);
> > > > > 504 }
> > > > > ------------------------------------------------------------
> > > > > 
> > > > > Another option is to change the priority of the memory allocation:
> > > > > net/ipv4/af_inet.c
> > > > > ------------------------------------------------------------
> > > > >  265 static int inet_create(struct net *net, struct socket *sock, int
> > > > > protocol,
> > > > >  266                        int kern)
> > > > >  267 {
> > > > > ...
> > > > >  345         sk = sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot);
> > > > > ------------------------------------------------------------
> > > > > Considering this is generic net code, I assume the GFP_KERNEL will not
> > > > > be replaced with GFP_ATOMIC.
> > > > > 
> > > > > NOTE, this is on RHEL 6.1 kernel 2.6.32-131.6.1 and apparently uses
> > > > > 'legacy' workqueue code.
> > > > > 
> > > > > cya,
> > > > > #
> > > > > 
> > > > 
> > > > I suspect this is also a problem in mainline, but maybe some of the
> > > > recent writeback changes prevent it...
> > > > 
> > > > I think the right solution here is to make nfs_release_page treat rpciod
> > > > similarly to kswapd. Easier said than done though -- you'll need to
> > > > come up with a way to determine if you're running in rpciod context...
> > > 
> > > No. The _right_ solution is to ensure that rpciod doesn't do allocations
> > > that result in a page reclaim... try_to_release_page() is just the tip
> > > of the iceberg of crazy deadlocks that this socket allocation can get us
> > > into.
> > > 
> > > Unfortunately, selinux & co. prevent us from allocating the sockets in
> > > user contexts, and anyway, having to wait for another thread to do the
> > > same allocation isn't doing to help prevent the deadlock...
> > > 
> > > I know that Mel Gorman's NFS swap patches had some protections against
> > > this sort of deadlock. Perhaps we can look at how he was doing this?
> > > 
> > 
> > Actually...now that I've looked at this, I think the right solution
> > here is to stop calling sock_release() on these sockets until we're in
> > xs_destroy. IOW, don't free the socket altogether unless we're truly
> > tearing down the connection for good. That means though that we need to
> > convert the places that currently call rpc_xprt_ops->close to call
> > something like a (new) ops->shutdown routine instead, with the
> > assumption of course that we can somehow reset and reuse the socket
> > afterward.
> > 
> > The question is how best to emulate the effect of ->close without
> > actually freeing the socket. Is it sufficient to call something like
> > kernel_sock_shutdown() on it, and twiddle all of the bits to ensure
> > that the connect_worker will get called afterward?
> 
> The reason why we close these sockets is that if the attempt at aborting
> the connection fails, then they typically end up in a TIME_WAIT state.
> 

I'm still trying to wade through the xprtsock.c socket handling code,
but it looks like we currently tear down the connection in 3 different
ways:

xs_close: which basically calls sock_release and gets rid of our
reference to an existing socket. Most of the places where we disconnect
the socket use this. After this, we end up with srcport == 0 which
makes it pick a new port.

xs_tcp_shutdown: which calls ->shutdown on it, but doesn't free
anything. This also preserves the existing srcport.

xs_abort_connection: calls kernel_connect to reconnect the socket to
AF_UNSPEC address (effectively disconnecting it?). This also preserves
the srcport. I guess we use this just before reconnecting when the
remote end drops the connection, since we don't need to be graceful
about tearing anything down at that point.

The last one actually does reuse the same socket, so my thinking was
that we could extend that scheme to the other cases. If we called
->shutdown on it and then reconnected it to AF_UNSPEC, would that
"reset" it back to a usable state?

If there really is no alternative to freeing the socket, then the only
real fix I can see is to set PF_MEMALLOC when we go to create it and
then reset it afterward. That's a pretty ugly fix though...

-- 
Jeff Layton <jlayton@redhat.com>
