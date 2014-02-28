Return-Path: linux-nfs-owner@vger.kernel.org
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:37639
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751711AbaB1Vra (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Feb 2014 16:47:30 -0500
Message-ID: <53110287.9000400@talpey.com>
Date: Fri, 28 Feb 2014 13:41:27 -0800
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
CC: Shirley Ma <shirley.ma@oracle.com>
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
In-Reply-To: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/26/2014 8:44 AM, Chuck Lever wrote:
> Hi-
>
> Shirley Ma and I are reviving work on the NFS/RDMA client code base in the Linux kernel.  So far we’ve built and run functional tests to determine what is working and what is broken.
>
> One complication is the number of memory registration modes supported by the RPC/RDMA transport: there are seven.  These were added over the years to support particular HCAs or as proof-of-concept.  The transport chooses a registration mode at mount time based on what the link HCA supports.
>
> Not all HCAs support all memory registration modes, so our test matrix is quite large.  I’d like to propose removing support for one or more of these memory registration modes in the name of making it easier to change this code and test it without breaking something that we can’t test.
>
> BOUNCEBUFFERS - All HCAs support this mode.  Does not use RDMA READ and WRITE, and the client end copies data into place.  RDMA is offloaded, by data copy is not.  I’m told it was never intended for production use.
>
> REGISTER - Safe but relatively slow.  Uses reg_phys_mr verb which is not supported in mlx4/mlx5, but all other HCAs/providers can use this mode.
>
> MEM_WINDOWS - Uses bind_mr verb.  Safe, but supports only a narrow range of HCAs.
>
> MEM_WINDOWS_ASYNC - Not always safe, and only a narrow range of HCAs is supported.
>
> MTHCA_FMR - Uses alloc_fmr verb.  Safe, reasonably fast, but only a narrow range of older HCAs is supported.

The MTHCA FMR is not completely safe - it protects only on page
boundaries, therefore the neighboring bytes are vulnerable to
silent corruption (reads) and exposure (write).

It is quite correct that they are supported on only a specific
set of legacy Mellanox HCA. You should consider removing the
code that looked for this PCI ID and attempted to alter the
device's wire MTU, to overcome another of its limitations.

>
> FRMR - Safe, generally fast.  Currently the preferred registration mode, but is not supported with some older HCAs/providers.

This should be, by far, the preferred mode. Also, if I recall
correctly, the server depends on this mode being available/supported.
However, it may not be supported by Soft iWARP. Physical addressing
is used.

>
> ALLPHYSICAL - Usually fast, but not safe as it exposes client memory.  All HCAs support this mode.

Not safe is an understatement. It exposes all of client physical
memory to the peer, for both read and write. A simple pointer error
on the server will silently corrupt the client. This mode was
intended only for testing, and in experimental deployments.


Tom.

>
>
> I propose removing BOUNCEBUFFERS since it is not intended for production use.
>
> I propose removing ALLPHYSICAL and MEM_WINDOWS_ASYNC as they are not generally safe.  RFC 5666 suggests that unsafe memory registration modes be avoided.
>
> I propose removing MEM_WINDOWS as it adds complexity without adding a lot of HCA compatibility.
>
> I propose removing MTHCA_FMR as I’m told it is hard to obtain HCAs we would need for testing this registration mode, and these are all old adapters anyway.
>
> This leaves NFS/RDMA client support for REGISTER and FRMR, which should cover all existing HCAs, and it is easy to test both of these memory registration modes with just one or two well-picked HCAs.
>
> We would contribute these changes to the client code base.  The NFS/RDMA server code could use similar attention, but we are not volunteering to change it at this time.
>
> Thoughts/comments?
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
