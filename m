From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [RFC][PATCH] nfs: don't assume fscache_acquire_cookie will always
 succeed
Date: Thu, 21 Jan 2010 17:11:25 +0530
Message-ID: <4B583D65.9040604@suse.de>
References: <4B56F565.7080104@suse.de> <29178.1264072027@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@netapp.com,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60917 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700Ab0AULld (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 06:41:33 -0500
In-Reply-To: <29178.1264072027@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/21/2010 04:37 PM, David Howells wrote:
> Suresh Jayaraman <sjayaraman@suse.de> wrote:
> 
>> +	if (!clp->fscache)
>> +		goto error_cleanup;
> 
> This should be unnecessary.  FS-Cache's API functions in linux/fscache.h
> should handle a NULL cookie and do the right thing.
> 

Did you mean __fscache_acquire_cookie() function or any other post
operations after the cookie has been acquired?

Because, nfs_fscache_get_client_cookie() calls fscache_acquire_cookie()
which inturn calls __fscache_acquire_cookie() that returns NULL if
kmem_cache_alloc fails and hence clp->fscache gets a negative cookie in
nfs_fscache_get_client_cookie.

I happened to stumble upon this code when I tried to investigate a bug
that reported a kerbel BUG in 2.6.32 while running LTP testsuite.

--snip--
kernel BUG at fs/nfs/fscache.c:360!

Here's the backtrace:

 #0 [ffff88001cc573e0] machine_kexec at ffffffff81021532
 #1 [ffff88001cc57430] crash_kexec at ffffffff81094280
 #2 [ffff88001cc57500] oops_end at ffffffff814b0290
 #3 [ffff88001cc57520] do_invalid_op at ffffffff81004af4
 #4 [ffff88001cc575c0] invalid_op at ffffffff81003cd5
 #5 [ffff88001cc57648] nfs_fscache_release_page at ffffffffa028a2cd
 #6 [ffff88001cc57690] shrink_page_list at ffffffff810e525e
 #7 [ffff88001cc57710] isolate_lru_pages at ffffffff810e47f3
 #8 [ffff88001cc577a0] shrink_inactive_list at ffffffff810e5669
 #9 [ffff88001cc57930] shrink_zone at ffffffff810e62c4
#10 [ffff88001cc579d0] shrink_zones at ffffffff810e63c3
#11 [ffff88001cc57a10] do_try_to_free_pages at ffffffff810e747d
#12 [ffff88001cc57a70] try_to_free_pages at ffffffff810e7832
#13 [ffff88001cc57ad0] __alloc_pages_slowpath at ffffffff810ddef3
#14 [ffff88001cc57b90] __alloc_pages_nodemask at ffffffff810de35c
#15 [ffff88001cc57bb0] load_balance_newidle at ffffffff81048c69
#16 [ffff88001cc57c80] ondemand_readahead at ffffffff810e1d43
#17 [ffff88001cc57cc0] do_generic_file_read at ffffffff810d8cfe
#18 [ffff88001cc57d40] generic_file_aio_read at ffffffff810d9536
#19 [ffff88001cc57dd0] do_sync_read at ffffffff81122f53
#20 [ffff88001cc57f00] vfs_read at ffffffff811237a7
#21 [ffff88001cc57f30] sys_read at ffffffff81123980
#22 [ffff88001cc57f80] system_call_fastpath at ffffffff81002f3b
    RIP: 00002b6e30d4b2b0  RSP: 00007fff30463528  RFLAGS: 00010206

--snip--

My interpretation of the BUG is:

Under low (seemingly very low) memory conditions, when we try to do a
NFS read and hence ondemand_readahead(), while trying to preallocate
memory, we find that get_page_from_freelist() didn't manage to find
pages from the free list and hence __alloc_pages_slowpath() is being
invoked.

Direct reclaim kicks in as our attempt to get free list fails even after
the background reclaim. Direct reclaim attempts to shrink caches. And in
shrink_page_list() we check if either page->PG_private or
page->PG_private1 (i.e. PG_fscache) flag is set before calling
try_to_release_page().

try_to_release_page() calls the nfs release_page method where the check
for PG_private fails and nfs_fscache_release_page() gets called and the
kernel BUGs when it finds nfsi->fscache is NULL.

The fact PG_private is not set in nfs_release_page implies that
PG_fscache is set for the page because of check in shrink_page_list()
which in turn implies it's a cache object and cookies should not be
NULL. It appears that the chances of a race condition is also unlikely
because we seem to be holding page lock in try_to_release_page().

This lead to the question of whether we are setting the cookie properly
in all cases and the allocation failure in fscache_acquire_cookie()
seemed like a potential place where it could still get set to NULL and
remain as it is.

Perhaps, my hypothesis has a hole or two or I'm miss something.



Thanks,

-- 
Suresh Jayaraman
