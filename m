Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50028 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751934AbdDHOYR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Apr 2017 10:24:17 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 00/34] dprintk() cleanup (part 1)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
Date: Sat, 8 Apr 2017 10:24:10 -0400
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B1E83C8C-A9A0-433B-AD21-95487C81B42D@oracle.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 7, 2017, at 2:14 PM, Anna.Schumaker@netapp.com wrote:
> 
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> We have around 750 dprintk()s in the NFS client alone, and many of these
> simply tell us when we're entering or leaving a function (usually both).
> This can create a lot of noise when you're trying to debug a single issues,
> and I think many dprintk()s can be cut out in favor of tracepoints or dynamic
> tracing through SystemTap.

Is there a description somewhere under Documentation for how
to enable and use each of these mechanisms?


> This patch set does just that. I went through some of our files one by one
> and removed dprintk()s that seemed to be unnecessary. Occasionally this
> allowed me to refactor the surrounding code, so I tried to make individual
> patches for each function I refactored.
> 
> These patches make changes to the following files:
>    - callback_proc.c
>    - callback_xdr.c
>    - client.c
>    - direct.c
>    - namespace.c
>    - nfs42proc.c
>    - nfs4client.c
>    - nfs4getroot.c
>    - nfs4namespace.c
>    - nfs4proc.c
> 
> What does everybody think?

I'm OK with clean up. Some random thoughts:

A more recent problem with dprintk debugging is the god-damned
journal rate limiting with imjournald and systemd. So IMO the
Linux NFS community has to come up with debugging tools that
do not run afoul of log message rate limiting.

If you're going to move forward with this project, should we
have a plan for removing dprintk in NFSD and the RPC layer as
well? (I've had a task on my to-do list for a while to replace
dprintk in rpcrdma.ko, but always there's something higher in
priority to work on).

Is there a plan for updating or replacing user space tooling
(ie. rpcdebug)?

Is there a desire to preserve the ability to compile out the
new debugging apparatus (tracepoints and so on)?

I think we want a "ruling" on whether dprintk and tracepoints
are considered part of a long-term kernel ABI/API. If they
are then such a conversion would mean a deeper commitment to
maintain specific tracepoints.


> Are any of these dprintk()s worth holding on to?
> 
> Thanks,
> Anna
> 
> 
> Anna Schumaker (34):
>  NFS: Clean up do_callback_layoutrecall()
>  NFS: Clean up nfs4_callback_layoutrecall()
>  NFS: Remove extra dprintk()s from callback_proc.c
>  NFS: Clean up decode_getattr_args()
>  NFS: Clean up decode_recall_args()
>  NFS: Clean up decode_layoutrecall_args()
>  NFS: Clean up decode_cb_sequence_args()
>  NFS: Clean up decode_notify_lock_args()
>  NFS: Clean up encode_cb_sequence_res()
>  NFS: Remove extra dprintk()s from callback_xdr.c
>  NFS: Clean up nfs_init_client()
>  NFS: Clean up extra dprintk()s in client.c
>  NFS: Remove nfs_direct_readpage_release()
>  NFS: Clean up nfs_direct_commit_complete()
>  NFS: Remove extra dprintk()s from namespace.c
>  NFS: Clean up nfs42_layoutstat_done()
>  NFS: Clean up nfs4_match_clientids()
>  NFS: Clean up nfs4_check_serverowner_minor_id()
>  NFS: Create a common nfs4_match_client() function
>  NFS: Clean up nfs4_check_serverowner_major_id()
>  NFS: Clean up nfs4_check_server_scope()
>  NFS: Clean up nfs4_set_client()
>  NFS: Clean up nfs4_init_server()
>  NFS: Remove extra dprintk()s from nfs4client.c
>  NFS: Clean up nfs4_get_rootfh()
>  NFS: Remove extra dprintk()s from nfs4namespace.c
>  NFS: Clean up nfs4_proc_bind_one_conn_to_session()
>  NFS: Clean up _nfs4_proc_exchange_id()
>  NFS: Clean up nfs4_proc_get_lease_time()
>  NFS: Clean up nfs41_proc_async_sequence()
>  NFS: Clean up nfs4_proc_sequence()
>  NFS: Clean up nfs41_proc_reclaim_complete()
>  NFS: Clean up nfs4_layoutget_handle_exception()
>  NFS: Remove extra dprintk()s from nfs4proc.c
> 
> fs/nfs/callback_proc.c |  41 +------
> fs/nfs/callback_xdr.c  | 109 +++++--------------
> fs/nfs/client.c        |  65 ++----------
> fs/nfs/direct.c        |  21 +---
> fs/nfs/namespace.c     |  34 ++----
> fs/nfs/nfs42proc.c     |   2 -
> fs/nfs/nfs4client.c    | 283 ++++++++++++++-----------------------------------
> fs/nfs/nfs4getroot.c   |   3 -
> fs/nfs/nfs4namespace.c |   7 +-
> fs/nfs/nfs4proc.c      | 274 +++++++----------------------------------------
> 10 files changed, 167 insertions(+), 672 deletions(-)
> 
> -- 
> 2.12.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



