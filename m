Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24302 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab0LPVE6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 16:04:58 -0500
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D0A74C5.1040104@gmail.com>
Date: Thu, 16 Dec 2010 16:04:38 -0500
Cc: Steve Dickson <SteveD@redhat.com>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Message-Id: <1C326FE3-22FF-4272-8D87-6242EB666297@oracle.com>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <4D0A6503.7010901@RedHat.com> <CD110562-AF52-4A2F-BF74-D7ABC4D58D24@oracle.com> <4D0A74C5.1040104@gmail.com>
To: Ric Wheeler <ricwheeler@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 16, 2010, at 3:21 PM, Ric Wheeler wrote:

> On 12/16/2010 03:04 PM, Chuck Lever wrote:
>> On Dec 16, 2010, at 2:14 PM, Steve Dickson wrote:
>> 
>>> Hello,
>>> 
>>> I was wondering if it would be possible hold off on committing major
>>> cleans ups like this one (and the RFC: Split nlm_host cache series)
>>> until pNFS wave3 is committed into either Trond's tree and/or in the
>>> mainline kernel.
>>> 
>>> I realize this is a huge request to make, something we've never done
>>> before. But talking with the powers to be on this end, include Ric
>>> Wheeler, accepting these types of patches before the pNFS bits
>>> settle down will make close to impossible for there to be any
>>> meaningful pNFS support in the RHEL 6 kernels. We would have
>>> to push the support off to RHEL 7.
>>> 
>>> The reasoning is this, which I do agree with, these types of
>>> patches, although probably needed, do not added any new features
>>> or fix any outstanding bugs.
>> The XDR series does add a new feature, FWIW: it adds buffer overflow protection to the client's reply processing logic.  Says so right in the patch descriptions.
> 
> Hi Chuck,
> 
> My concern is one of testing one massive set of changes at a time and trying to get those stable (and through QA) before code refactoring. We have been focused on the pNFS bits for what feels like eons and they seem to be getting *really* close now :)

Likewise, these XDR changes have been floating around since 2007 :-)  I'd rather not be penalized yet again because of the timing of other work.

> I certainly do not object to this work, just want to get the pNFS flood absorbed and processed first.
> 
> The risk of putting it all in the hopper together is that testing and debugging (in upstream, non-vendor distros and vendor distros) gets harder to qa, debug if/when issues arise  and get stable.

Except for the across-the-board API change, the NFSv2 and NFSv3 XDR patches are entirely unrelated to pNFS.  Debugging, if any is needed, and QA can be done completely in parallel and by different developers (upstream).  Problems in that code will not have any effect on NFSv4 or pNFS.

Again, you guys can lean on us upstream folks to help with troubleshooting and providing fixes.  Any fixes for bugs you find will have to come upstream anyway.

> It would certainly help us to stage pulling the XDR clean up work until after we settle the various pNFS "waves" of change, but I can also understand why you would prefer to push them in sooner.

In principal, I can understand why you might hesitate to allow this change too.  But someone got scared by looking just at the patch count.  "fscache" this ain't.  There's a difference between complexity and changes that are simply broad.

XDR is so basic that it will be obvious when something critical isn't right and how to fix it.  Bruce has already passed this through his magic automated test suite, multiple times.  A pass through linux-next will identify any significant remaining issues.

Based on the age of these patches, the fact that any problems will likely be obvious, and the amount of testing they've already received, I expect it won't be anywhere near the kind of QA workload that pNFS will be.  However, I'd like to move forward with actual evidence about what it might cost you.  You can start looking at these now by pulling my git repo (git.linux-nfs.org cel-2.6) and trying a run through your QA cycle.  If you find a high defect rate, we can stop this conversation and hold off.


> Thanks!
> 
> Ric
> 
>>> More likely than not (for a time) they will
>>> add some instability due to the lack of usage and testing.  These type of
>>> changes are much too large for even our QE group to test and verify and
>>> obviously instability is the last thing we can interject into an
>>> on going enterprise product stream.
>> The only NFSv4-related changes in this series are limited to refactoring.  No behavior changes are made in the NFSv4 code.  The bulk of the changes effect only NFSv2 and NFSv3, and will have no impact on pNFS (other than a minor API change).
>> 
>> XDR is straightforward and well understood.  If anything is broken by these patches, I expect it will be exposed quickly.
>> 
>> The NLM patches also have nothing to do with pNFS, AFAICT, and can likely be skipped for RHEL 6.
>> 
>>> Again, I realize what we are asking and how big this request
>>> really is. Its just that we've come so far and are pretty close
>>> (IMHO) to have some meaningful  pNFS support in RHEL 6, I
>>> figured I'd take a shoot and ask...
>> I don't think these are as world-bending as you believe.  I'm happy to discuss the actual changes with Ric.
>> 
>>> steved.
>>> 
>>> On 12/14/2010 09:54 AM, Chuck Lever wrote:
>>>> Trond-
>>>> 
>>>> As requested, here is my latest revision of the XDR patchset for
>>>> 2.6.38.
>>>> 
>>>> This converts NFSv2 and v3, all versions of NLM, and the server's
>>>> NFSv4 callback client.  It updates the XDR code for rpcbind, NSM, and
>>>> MNT as well.
>>>> 
>>>> All encoders and decoders now use xdr_streams.  All encoders now BUG
>>>> on any error and return void.
>>>> 
>>>> As a bonus, this series converts the whole kit and kaboodle to a new
>>>> calling sequence.  The RPC client's generic encode and decode routines
>>>> now invoke xdr_init_{en,de}code before calling the specific XDR
>>>> routines.  The xdr_init_{en,de}code call sites are thus removed from
>>>> all specific XDR routines in the kernel.
>>>> 
>>>> ---
>>>> 
>>>> Chuck Lever (31):
>>>>      SUNRPC: New xdr_streams XDR decoder API
>>>>      SUNRPC: New xdr_streams XDR encoder API
>>>>      SUNRPC: Determine value of "nrprocs" automatically
>>>>      SUNRPC: Avoid return code checking in rpcbind XDR encoder functions
>>>>      NFS: Remove unused UMNT response data structure
>>>>      NFS: Avoid return code checking in mount XDR encoder functions
>>>>      NSM: Avoid return code checking in NSM XDR encoder functions
>>>>      NFS: Squelch compiler warning in decode_getdeviceinfo()
>>>>      NFS: Simplify ->decode_dirent() calling sequence
>>>>      NFS: Fix hdrlen calculation in NFSv4's decode_read()
>>>>      lockd: Move nlmdbg_cookie2a() to svclock.c
>>>>      NFS: Repair whitespace damage in NFS PROC macro
>>>>      NFSD: Update XDR decoders in NFSv4 callback client
>>>>      NFSD: Update XDR encoders in NFSv4 callback client
>>>>      lockd: Introduce new-style XDR functions for NLMv4
>>>>      NFS: Move and update xdr_decode_foo() functions that we're keeping
>>>>      NFS: Remove unused old NFSv3 decoder functions
>>>>      NFS: Switch in new NFSv3 decoder functions
>>>>      NFS: Introduce new-style XDR decoding functions for NFSv2
>>>>      NFS: Update xdr_encode_foo() functions that we're keeping
>>>>      NFS: Remove unused old NFSv3 encoder functions
>>>>      NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
>>>>      NFS: Introduce new-style XDR encoding functions for NFSv3
>>>>      lockd: Introduce new-style XDR functions for NLMv3
>>>>      NFS: Move and update xdr_decode_foo() functions that we're keeping
>>>>      NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
>>>>      NFS: Introduce new-style XDR decoding functions for NFSv2
>>>>      NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s argument
>>>>      NFS: Update xdr_encode_foo() functions that we're keeping
>>>>      NFS: Remove old NFSv2 encoder functions
>>>>      NFS: Introduce new-style XDR encoding functions for NFSv2
>>>> 
>>>> 
>>>> fs/lockd/Makefile              |    6
>>>> fs/lockd/clnt4xdr.c            |  605 ++++++++
>>>> fs/lockd/clntxdr.c             |  627 +++++++++
>>>> fs/lockd/mon.c                 |  110 +-
>>>> fs/lockd/svclock.c             |   30
>>>> fs/lockd/xdr.c                 |  287 ----
>>>> fs/lockd/xdr4.c                |  255 ----
>>>> fs/nfs/dir.c                   |   15
>>>> fs/nfs/internal.h              |   11
>>>> fs/nfs/mount_clnt.c            |   81 -
>>>> fs/nfs/nfs2xdr.c               | 1297 ++++++++++++------
>>>> fs/nfs/nfs3xdr.c               | 2892 +++++++++++++++++++++++++++++-----------
>>>> fs/nfs/nfs4_fs.h               |    1
>>>> fs/nfs/nfs4xdr.c               | 1401 +++++++++----------
>>>> fs/nfs/proc.c                  |    2
>>>> fs/nfsd/nfs4callback.c         |  690 ++++++----
>>>> include/linux/lockd/debug.h    |   10
>>>> include/linux/nfs3.h           |    3
>>>> include/linux/nfs_xdr.h        |    3
>>>> include/linux/sunrpc/auth.h    |    8
>>>> include/linux/sunrpc/clnt.h    |    4
>>>> include/linux/sunrpc/xdr.h     |   10
>>>> net/sunrpc/auth.c              |   28
>>>> net/sunrpc/auth_gss/auth_gss.c |   44 -
>>>> net/sunrpc/clnt.c              |    9
>>>> net/sunrpc/rpcb_clnt.c         |  147 +-
>>>> 26 files changed, 5529 insertions(+), 3047 deletions(-)
>>>> create mode 100644 fs/lockd/clnt4xdr.c
>>>> create mode 100644 fs/lockd/clntxdr.c
>>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




