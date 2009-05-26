From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] nfs-utils: add IPv6 support for rpc.nfsd (try #2)
Date: Tue, 26 May 2009 11:24:57 -0400
Message-ID: <5889D6C8-2E49-430C-A2DF-F85F57637A63@oracle.com>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:54780 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016AbZEZP0n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2009 11:26:43 -0400
In-Reply-To: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 26, 2009, at 11:15 AM, Jeff Layton wrote:
> This is the second attempt to add support IPv6 to rpc.nfsd. The main
> changes since the last patchset are:
>
> 1) the addition of a patch that makes nfsd look at /etc/netconfig when
> tirpc is enabled, and to disable any family/protocol combinations that
> don't have visible netid's.
>
> 2) stop linking in some unneeded .a libs.
>
> 3) some minor bugfixes
>
> 4) update to the nfsd manpage for new options
>
> I think the set is bisectable, but have only really tested the final
> result. I've also tested the final result when built with tirpc  
> enabled
> and disabled, and ipv6 enabled and disabled.
>
> I haven't seen any regressions when testing on recent mainline kernels
> and The only real difference that anyone may notice is that when IPv6
> support is built in, and the kernel doesn't support IPv6, nfsd logs  
> this
> message a couple of times when starting nfsd:
>
> nfssvc: writing fds to kernel failed: errno 97 (Address family not  
> supported by protocol)

We should also ensure this behaves itself if IPv6 support is built  
into the kernel, but ipv6.ko is blacklisted.

> Most of the testing I've done has been by watching the program under
> strace.  Since most of the kernel work for IPv6 support hasn't made it
> to mainline, it's a little difficult to do much testing of this beyond
> that.
>
> Jeff Layton (6):
>  nfs-utils: don't link libexport.a and libmisc.a to nfsd
>  nfs-utils: break up nfssvc.c into more individually callable
>    functions
>  nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
>  nfs-utils: add IPv6 support to nfsd
>  nfs-utils: limit protocols and families used by nfsd to those listed
>    in /etc/netconfig
>  nfs-utils: add -4 and -6 options to nfsd manpage
>
> support/include/nfslib.h |    8 ++-
> support/nfs/nfssvc.c     |  164 ++++++++++++++++++++++++++++++++ 
> +----------
> utils/nfsd/Makefile.am   |    4 +-
> utils/nfsd/nfsd.c        |  175 +++++++++++++++++++++++++++++++++++++ 
> +--------
> utils/nfsd/nfsd.man      |   10 +++
> 5 files changed, 292 insertions(+), 69 deletions(-)
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



