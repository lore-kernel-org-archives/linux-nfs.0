Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54038 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab3CCAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Mar 2013 19:38:42 -0500
Date: Sat, 2 Mar 2013 19:38:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: nfsd changes for 3.9
Message-ID: <20130303003829.GB20389@fieldses.org>
References: <20130228184521.GB30236@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130228184521.GB30236@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2013 at 01:45:21PM -0500, bfields wrote:
> Please pull nfsd changes for 3.9 from the for-3.9 branch at:
> 
>   git://linux-nfs.org/~bfields/linux.git for-3.9

And thanks for handling the merge problems!  The results look right.

--b.

> 
> Miscellaneous bugfixes, plus:
> 
> 	- An overhaul of the DRC cache by Jeff Layton.  The main effect
> 	  is just to make it larger.  This decreases the chances of
> 	  intermittent errors especially in the UDP case.  But we'll
> 	  need to watch for any reports of performance regressions.
> 
> 	- Containerized nfsd: with some limitations, we now support
> 	  per-container nfs-service, thanks to extensive work from
> 	  Stanislav Kinsbursky over the last year.
> 
> --b.
> 
> ----------------------------------------------------------------
> Andriy Skulysh (1):
>       sunrpc: Fix lockd sleeping until timeout
> 
> Fengguang Wu (1):
>       nfsd4: free_stid can be static
> 
> J. Bruce Fields (7):
>       nfsd4: simplify nfsd4_encode_fattr interface slightly
>       svcrpc: silence "unused variable" warning in !RPC_DEBUG case
>       nfsd4: require version 4 when enabling or disabling minorversion
>       nfsd4: simplify idr allocation
>       svcrpc: make svc_age_temp_xprts enqueue under sv_lock
>       svcrpc: fix rpc server shutdown races
>       SUNRPC: make AF_LOCAL connect synchronous
> 
> Jeff Layton (23):
>       nfsd: fix IPv6 address handling in the DRC
>       nfsd: remove unneeded spinlock in nfsd_cache_update
>       nfsd: get rid of RC_INTR
>       nfsd: create a dedicated slabcache for DRC entries
>       nfsd: add alloc and free functions for DRC entries
>       nfsd: remove redundant test from nfsd_reply_cache_free
>       nfsd: clean up and clarify the cache expiration code
>       nfsd: break out hashtable search into separate function
>       nfsd: initialize the exp->ex_uuid field in svc_export_init
>       nfsd: always move DRC entries to the end of LRU list when updating timestamp
>       nfsd: track the number of DRC entries in the cache
>       nfsd: dynamically allocate DRC entries
>       nfsd: remove the cache_disabled flag
>       nfsd: when updating an entry with RC_NOCACHE, just free it
>       nfsd: add recurring workqueue job to clean the cache
>       nfsd: register a shrinker for DRC cache entries
>       sunrpc: copy scope ID in __rpc_copy_addr6
>       sunrpc: move address copy/cmp/convert routines and prototypes from clnt.h to addr.h
>       sunrpc: fix comment in struct xdr_buf definition
>       sunrpc: trim off trailing checksum before returning decrypted or integrity authenticated buffer
>       nfsd: keep a checksum of the first 256 bytes of request
>       nfsd: fix comments on nfsd_cache_lookup
>       nfsd: fix compiler warning about ambiguous types in nfsd_cache_csum
> 
> Stanislav Kinsbursky (11):
>       nfsd: fix unused "nn" variable warning in free_client()
>       NFS: use SUNRPC cache creation and destruction helper for DNS cache
>       NFS: simplify and clean cache library
>       SUNRPC: introduce cache_detail->cache_request callback
>       SUNRPC: rework cache upcall logic
>       SUNRPC: remove "cache_request" argument in sunrpc_cache_pipe_upcall() function
>       SUNRPC: move cache_detail->cache_request callback call to cache_read()
>       nfsd: containerize NFSd filesystem
>       nfsd: use proper net while reading "exports" file
>       nfsd: disable usermode helper client tracker in container
>       nfsd: enable NFSv4 state in containers
> 
> Tim Gardner (1):
>       lockd: nlmclnt_reclaim(): avoid stack overflow
> 
> Yanchuan Nian (3):
>       nfsd: Pass correct slot number to nfsd4_put_drc_mem()
>       nfsd: Don't unlock the state while it's not locked
>       nfsd: Remove write permission from file content
> 
> majianpeng (2):
>       nfsd: Fix memleak in svc_export_put
>       nfsd: Fix memleak
> 
>  fs/lockd/clntlock.c                 |  14 +-
>  fs/lockd/clntproc.c                 |   6 +-
>  fs/lockd/host.c                     |   1 +
>  fs/lockd/mon.c                      |   1 +
>  fs/lockd/svcsubs.c                  |   2 +-
>  fs/nfs/cache_lib.c                  |  12 +-
>  fs/nfs/cache_lib.h                  |   2 -
>  fs/nfs/dns_resolve.c                |  67 +++----
>  fs/nfs/nfs4client.c                 |   1 +
>  fs/nfs/nfs4filelayoutdev.c          |   1 +
>  fs/nfs/nfs4namespace.c              |   1 +
>  fs/nfs/super.c                      |   1 +
>  fs/nfsd/cache.h                     |  17 +-
>  fs/nfsd/export.c                    |  16 +-
>  fs/nfsd/fault_inject.c              |   2 +-
>  fs/nfsd/nfs4idmap.c                 |  16 +-
>  fs/nfsd/nfs4proc.c                  |   7 +-
>  fs/nfsd/nfs4recover.c               |   6 +
>  fs/nfsd/nfs4state.c                 | 102 ++++++-----
>  fs/nfsd/nfs4xdr.c                   |  21 +--
>  fs/nfsd/nfscache.c                  | 354 ++++++++++++++++++++++++++++--------
>  fs/nfsd/nfsctl.c                    |  81 ++++++---
>  fs/nfsd/nfssvc.c                    |   6 +-
>  fs/nfsd/xdr4.h                      |   2 +-
>  include/linux/lockd/lockd.h         |   3 +-
>  include/linux/sunrpc/addr.h         | 170 +++++++++++++++++
>  include/linux/sunrpc/cache.h        |  10 +-
>  include/linux/sunrpc/clnt.h         | 152 ----------------
>  include/linux/sunrpc/svc.h          |   1 +
>  include/linux/sunrpc/xdr.h          |   3 +-
>  net/sunrpc/addr.c                   |   3 +-
>  net/sunrpc/auth_gss/gss_krb5_wrap.c |   2 +
>  net/sunrpc/auth_gss/svcauth_gss.c   |  18 +-
>  net/sunrpc/cache.c                  |  51 +++---
>  net/sunrpc/clnt.c                   |   1 +
>  net/sunrpc/rpcb_clnt.c              |   1 +
>  net/sunrpc/svc.c                    |  13 +-
>  net/sunrpc/svc_xprt.c               |  81 +++++----
>  net/sunrpc/svcauth_unix.c           |  16 +-
>  net/sunrpc/xdr.c                    |  41 +++++
>  net/sunrpc/xprtrdma/transport.c     |   1 +
>  net/sunrpc/xprtsock.c               |  36 +++-
>  42 files changed, 834 insertions(+), 508 deletions(-)
>  create mode 100644 include/linux/sunrpc/addr.h
