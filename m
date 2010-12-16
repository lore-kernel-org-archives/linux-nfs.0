Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754184Ab0LPTON (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Dec 2010 14:14:13 -0500
Message-ID: <4D0A6503.7010901@RedHat.com>
Date: Thu, 16 Dec 2010 14:14:11 -0500
From: Steve Dickson <SteveD@redhat.com>
To: trond.myklebust@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I was wondering if it would be possible hold off on committing major 
cleans ups like this one (and the RFC: Split nlm_host cache series) 
until pNFS wave3 is committed into either Trond's tree and/or in the
mainline kernel. 

I realize this is a huge request to make, something we've never done
before. But talking with the powers to be on this end, include Ric 
Wheeler, accepting these types of patches before the pNFS bits 
settle down will make close to impossible for there to be any 
meaningful pNFS support in the RHEL 6 kernels. We would have 
to push the support off to RHEL 7.

The reasoning is this, which I do agree with, these types of 
patches, although probably needed, do not added any new features 
or fix any outstanding bugs. More likely than not (for a time) they will 
add some instability due to the lack of usage and testing. These type of 
changes are much too large for even our QE group to test and verify and
obviously instability is the last thing we can interject into an 
on going enterprise product stream.
 
Again, I realize what we are asking and how big this request
really is. Its just that we've come so far and are pretty close 
(IMHO) to have some meaningful  pNFS support in RHEL 6, I 
figured I'd take a shoot and ask... 

steved.

On 12/14/2010 09:54 AM, Chuck Lever wrote:
> Trond-
> 
> As requested, here is my latest revision of the XDR patchset for
> 2.6.38.
> 
> This converts NFSv2 and v3, all versions of NLM, and the server's
> NFSv4 callback client.  It updates the XDR code for rpcbind, NSM, and
> MNT as well.
> 
> All encoders and decoders now use xdr_streams.  All encoders now BUG
> on any error and return void.
> 
> As a bonus, this series converts the whole kit and kaboodle to a new
> calling sequence.  The RPC client's generic encode and decode routines
> now invoke xdr_init_{en,de}code before calling the specific XDR
> routines.  The xdr_init_{en,de}code call sites are thus removed from
> all specific XDR routines in the kernel.
> 
> ---
> 
> Chuck Lever (31):
>       SUNRPC: New xdr_streams XDR decoder API
>       SUNRPC: New xdr_streams XDR encoder API
>       SUNRPC: Determine value of "nrprocs" automatically
>       SUNRPC: Avoid return code checking in rpcbind XDR encoder functions
>       NFS: Remove unused UMNT response data structure
>       NFS: Avoid return code checking in mount XDR encoder functions
>       NSM: Avoid return code checking in NSM XDR encoder functions
>       NFS: Squelch compiler warning in decode_getdeviceinfo()
>       NFS: Simplify ->decode_dirent() calling sequence
>       NFS: Fix hdrlen calculation in NFSv4's decode_read()
>       lockd: Move nlmdbg_cookie2a() to svclock.c
>       NFS: Repair whitespace damage in NFS PROC macro
>       NFSD: Update XDR decoders in NFSv4 callback client
>       NFSD: Update XDR encoders in NFSv4 callback client
>       lockd: Introduce new-style XDR functions for NLMv4
>       NFS: Move and update xdr_decode_foo() functions that we're keeping
>       NFS: Remove unused old NFSv3 decoder functions
>       NFS: Switch in new NFSv3 decoder functions
>       NFS: Introduce new-style XDR decoding functions for NFSv2
>       NFS: Update xdr_encode_foo() functions that we're keeping
>       NFS: Remove unused old NFSv3 encoder functions
>       NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
>       NFS: Introduce new-style XDR encoding functions for NFSv3
>       lockd: Introduce new-style XDR functions for NLMv3
>       NFS: Move and update xdr_decode_foo() functions that we're keeping
>       NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
>       NFS: Introduce new-style XDR decoding functions for NFSv2
>       NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s argument
>       NFS: Update xdr_encode_foo() functions that we're keeping
>       NFS: Remove old NFSv2 encoder functions
>       NFS: Introduce new-style XDR encoding functions for NFSv2
> 
> 
>  fs/lockd/Makefile              |    6 
>  fs/lockd/clnt4xdr.c            |  605 ++++++++
>  fs/lockd/clntxdr.c             |  627 +++++++++
>  fs/lockd/mon.c                 |  110 +-
>  fs/lockd/svclock.c             |   30 
>  fs/lockd/xdr.c                 |  287 ----
>  fs/lockd/xdr4.c                |  255 ----
>  fs/nfs/dir.c                   |   15 
>  fs/nfs/internal.h              |   11 
>  fs/nfs/mount_clnt.c            |   81 -
>  fs/nfs/nfs2xdr.c               | 1297 ++++++++++++------
>  fs/nfs/nfs3xdr.c               | 2892 +++++++++++++++++++++++++++++-----------
>  fs/nfs/nfs4_fs.h               |    1 
>  fs/nfs/nfs4xdr.c               | 1401 +++++++++----------
>  fs/nfs/proc.c                  |    2 
>  fs/nfsd/nfs4callback.c         |  690 ++++++----
>  include/linux/lockd/debug.h    |   10 
>  include/linux/nfs3.h           |    3 
>  include/linux/nfs_xdr.h        |    3 
>  include/linux/sunrpc/auth.h    |    8 
>  include/linux/sunrpc/clnt.h    |    4 
>  include/linux/sunrpc/xdr.h     |   10 
>  net/sunrpc/auth.c              |   28 
>  net/sunrpc/auth_gss/auth_gss.c |   44 -
>  net/sunrpc/clnt.c              |    9 
>  net/sunrpc/rpcb_clnt.c         |  147 +-
>  26 files changed, 5529 insertions(+), 3047 deletions(-)
>  create mode 100644 fs/lockd/clnt4xdr.c
>  create mode 100644 fs/lockd/clntxdr.c
> 
