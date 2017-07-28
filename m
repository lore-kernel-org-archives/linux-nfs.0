Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24124 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdG1T7z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jul 2017 15:59:55 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 00/20] Reducing inode->i_lock contention in writebacks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <29B1641A-1D00-4CD3-8FBD-4B1D211D3AD7@oracle.com>
Date: Fri, 28 Jul 2017 15:59:49 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <ECB81AFC-2D8A-4440-A0D1-93772D505814@oracle.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com> <29B1641A-1D00-4CD3-8FBD-4B1D211D3AD7@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 28, 2017, at 1:26 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> 
>> On Jul 19, 2017, at 6:09 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>> Chuck Lever has presented measurements, that would appear to indicate that
>> the inode->i_lock can be a source of contention when doing writeback using
>> high performance networks. This patch series is therefore an attempt to
>> address the sources of contention that his measurements pointed to.
>> 
>> According to Chuck's table, the main sources of contention appear to
>> be in nfs_flush_incompatible(), nfs_lock_and_join_requests() and
>> nfs_updatepage(). Most of this patch series focuses on fixing
>> nfs_lock_and_join_requests(), since it holds the inode lock, while
>> taking locks on the page group and the sub-requests themselves,
>> rolling them all back if ever there is contention.
>> By noting a few simple rules that are mostly already in place, we
>> can simplify that locking to ensure that we only have to keep the
>> spin lock while we're dereferencing and locking the head page pointer
>> that is stored in page_private(page).
>> 
>> Along the way, the patches also simplify the code a little, and fix
>> a number of subtle races which mainly occur when you set wsize to
>> some value smaller than the page size. The most notable such race
>> occurs between nfs_lock_and_join_requests() and nfs_page_group_destroy(),
>> and could lead to a double free() of some of the sub-requests.
>> 
>> Finally, there are 2 patches tacked onto the end of the series that
>> attempt to improve the throttling of writes when the RPC layer is
>> congested. They do so by forcing each caller of nfs_initiate_pgio()
>> to wait until the request is being transmitted. The expectation is
>> that this might help improve latencies when there are several processes
>> competing for access to the RPC transport.
>> 
>> Trond Myklebust (20):
>> NFS: Simplify page writeback
>> NFS: Reduce lock contention in nfs_page_find_head_request()
>> NFS: Reduce lock contention in nfs_try_to_update_request()
>> NFS: Ensure we always dereference the page head last
>> NFS: Fix a reference and lock leak in nfs_lock_and_join_requests()
>> NFS: Fix an ABBA issue in nfs_lock_and_join_requests()
>> NFS: Don't check request offset and size without holding a lock
>> NFS: Don't unlock writebacks before declaring PG_WB_END
>> NFS: Fix the inode request accounting when pages have subrequests
>> NFS: Teach nfs_try_to_update_request() to deal with request
>>   page_groups
>> NFS: Remove page group limit in nfs_flush_incompatible()
>> NFS: Reduce inode->i_lock contention in nfs_lock_and_join_requests()
>> NFS: Further optimise nfs_lock_and_join_requests()
>> NFS: Fix nfs_page_group_destroy() and nfs_lock_and_join_requests()
>>   race cases
>> NFS: Remove nfs_page_group_clear_bits()
>> NFS: Remove unuse function nfs_page_group_lock_wait()
>> NFS: Remove unused parameter from nfs_page_group_lock()
>> NFS: Fix up nfs_page_group_covers_page()
>> SUNRPC: Add a function to allow waiting for RPC transmission
>> NFS: Throttle I/O to the NFS server
>> 
>> fs/nfs/pagelist.c            |  64 +++------
>> fs/nfs/write.c               | 313 ++++++++++++++++++-------------------------
>> include/linux/nfs_page.h     |   3 +-
>> include/linux/sunrpc/sched.h |   3 +
>> net/sunrpc/sched.c           |  22 +++
>> net/sunrpc/xprt.c            |   6 +
>> 6 files changed, 177 insertions(+), 234 deletions(-)
> 
> Sorry for the delay.
> 
> I reviewed the patches. 1-10 were straightforward, but 11-18 appear to
> assume some local knowledge about how this code path is architected, so
> I can't make an informed comment on those. The only thing I would say is
> that if you go with 19 and 20, consider adding a similar governor to the
> DELEGRETURN path.
> 
> I've had a few moments to run some basic tests with this series, applied
> to v4.13-rc1. The client is dual-socket 12-core CPU with CX3 Pro Infini-
> Band running at 56Gbps.
> 
> 	• No new functional problems were observed.
> 	• RPC backlog queues definitely are smaller.
> 	• Throughput of large payload I/O (>1MB) is higher.
> 	• Latency of 1KB I/O is a little faster.
> 	• fio IOPS throughput is lower.
> 
> The fio 8KB 70/30 test concerns me: it's usually about 105/45 KIOPS, but
> with the patches it's 76/33. I also noticed that my iozone-based 8KB IOPS
> test shows read IOPS throughput is about 5% lower.
> 
> So, it's a mixed bag of macro benchmark results. I can try bisecting if
> you are interested.

Popping off 19 and 20 eliminated the fio performance regression.


> I also ran lock contention tests. I used:
> 
>  iozone -i0 -i1 -s2g -y1k -az -c
> 
> Contention appears to be reduced, but i_lock is still the most contended
> lock in the system by far during this test. During an equivalent direct
> I/O test, I notice i_lock acquisitions increasing, but contentions do not.
> 
> A copy of /proc/lock_stat is attached for a stock v4.13-rc1 kernel, and
> for the same kernel plus your patches. This is for just the iozone
> command line listed above.
> 
> 
> --
> Chuck Lever
> 
> 
> <lock_stat-4.13.0-rc1><lock_stat-4.13.0-rc1-00020-g1ee454a>

--
Chuck Lever



