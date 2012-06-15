Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814Ab2FONVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jun 2012 09:21:06 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q5FDL6hR015989
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 15 Jun 2012 09:21:06 -0400
Date: Fri, 15 Jun 2012 09:21:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Harshula <harshula@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpciod process is blocked in nfs_release_page waiting for
 nfs_commit_inode to complete
Message-ID: <20120615092103.15cc2b11@corrin.poochiereds.net>
In-Reply-To: <1339764850.30233.11.camel@serendib>
References: <1339764850.30233.11.camel@serendib>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Jun 2012 22:54:10 +1000
Harshula <harshula@redhat.com> wrote:

> Hi All,
> 
> Can I please get your feedback on the following?
> 
> rpciod is blocked:
> ------------------------------------------------------------
> crash> bt  2507 
> PID: 2507   TASK: ffff88103691ab40  CPU: 14  COMMAND: "rpciod/14"
>  #0 [ffff8810343bf2f0] schedule at ffffffff814dabd9
>  #1 [ffff8810343bf3b8] nfs_wait_bit_killable at ffffffffa038fc04 [nfs]
>  #2 [ffff8810343bf3c8] __wait_on_bit at ffffffff814dbc2f
>  #3 [ffff8810343bf418] out_of_line_wait_on_bit at ffffffff814dbcd8
>  #4 [ffff8810343bf488] nfs_commit_inode at ffffffffa039e0c1 [nfs]
>  #5 [ffff8810343bf4f8] nfs_release_page at ffffffffa038bef6 [nfs]
>  #6 [ffff8810343bf528] try_to_release_page at ffffffff8110c670
>  #7 [ffff8810343bf538] shrink_page_list.clone.0 at ffffffff81126271
>  #8 [ffff8810343bf668] shrink_inactive_list at ffffffff81126638
>  #9 [ffff8810343bf818] shrink_zone at ffffffff8112788f
> #10 [ffff8810343bf8c8] do_try_to_free_pages at ffffffff81127b1e
> #11 [ffff8810343bf958] try_to_free_pages at ffffffff8112812f
> #12 [ffff8810343bfa08] __alloc_pages_nodemask at ffffffff8111fdad
> #13 [ffff8810343bfb28] kmem_getpages at ffffffff81159942
> #14 [ffff8810343bfb58] fallback_alloc at ffffffff8115a55a
> #15 [ffff8810343bfbd8] ____cache_alloc_node at ffffffff8115a2d9
> #16 [ffff8810343bfc38] kmem_cache_alloc at ffffffff8115b09b
> #17 [ffff8810343bfc78] sk_prot_alloc at ffffffff81411808
> #18 [ffff8810343bfcb8] sk_alloc at ffffffff8141197c
> #19 [ffff8810343bfce8] inet_create at ffffffff81483ba6
> #20 [ffff8810343bfd38] __sock_create at ffffffff8140b4a7
> #21 [ffff8810343bfd98] xs_create_sock at ffffffffa01f649b [sunrpc]
> #22 [ffff8810343bfdd8] xs_tcp_setup_socket at ffffffffa01f6965 [sunrpc]
> #23 [ffff8810343bfe38] worker_thread at ffffffff810887d0
> #24 [ffff8810343bfee8] kthread at ffffffff8108dd96
> #25 [ffff8810343bff48] kernel_thread at ffffffff8100c1ca
> ------------------------------------------------------------
> 
> nfs_release_page() gives kswapd process an exemption from being blocked.
> Should we do the same for rpciod. Otherwise rpciod could end up in a
> deadlock where it can not continue without freeing memory that will only
> become available when rpciod does its work:
> ------------------------------------------------------------
> 479 /*
> 480  * Attempt to release the private state associated with a page
> 481  * - Called if either PG_private or PG_fscache is set on the page
> 482  * - Caller holds page lock
> 483  * - Return true (may release page) or false (may not)
> 484  */
> 485 static int nfs_release_page(struct page *page, gfp_t gfp)
> 486 {   
> 487         struct address_space *mapping = page->mapping;
> 488     
> 489         dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
> 490     
> 491         /* Only do I/O if gfp is a superset of GFP_KERNEL */
> 492         if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
> 493                 int how = FLUSH_SYNC;
> 494             
> 495                 /* Don't let kswapd deadlock waiting for OOM RPC calls */
> 496                 if (current_is_kswapd())
> 497                         how = 0;
> 498                 nfs_commit_inode(mapping->host, how);
> 499         }
> 500         /* If PagePrivate() is set, then the page is not freeable */
> 501         if (PagePrivate(page))
> 502                 return 0;
> 503         return nfs_fscache_release_page(page, gfp);
> 504 }
> ------------------------------------------------------------
> 
> Another option is to change the priority of the memory allocation:
> net/ipv4/af_inet.c
> ------------------------------------------------------------
>  265 static int inet_create(struct net *net, struct socket *sock, int
> protocol,
>  266                        int kern)
>  267 {
> ...
>  345         sk = sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot);
> ------------------------------------------------------------
> Considering this is generic net code, I assume the GFP_KERNEL will not
> be replaced with GFP_ATOMIC.
> 
> NOTE, this is on RHEL 6.1 kernel 2.6.32-131.6.1 and apparently uses
> 'legacy' workqueue code.
> 
> cya,
> #
> 

I suspect this is also a problem in mainline, but maybe some of the
recent writeback changes prevent it...

I think the right solution here is to make nfs_release_page treat rpciod
similarly to kswapd. Easier said than done though -- you'll need to
come up with a way to determine if you're running in rpciod context...

-- 
Jeff Layton <jlayton@redhat.com>
