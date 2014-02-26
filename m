Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailuogwhop.emc.com ([168.159.213.141]:16285 "EHLO
	mailuogwhop.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbaBZRnD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2014 12:43:03 -0500
From: "faibish, sorin" <faibish_sorin@emc.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
CC: Shirley Ma <shirley.ma@oracle.com>
Date: Wed, 26 Feb 2014 12:42:52 -0500
Subject: RE: Proposal for simplifying NFS/RDMA client memory registration
Message-ID: <2512424DBC01FD48843E938C780FA97C02C4701C48@MX23A.corp.emc.com>
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
In-Reply-To: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Chuck Lever
Sent: Wednesday, February 26, 2014 11:45 AM
To: linux-rdma@vger.kernel.org; Linux NFS Mailing List
Cc: Shirley Ma
Subject: Proposal for simplifying NFS/RDMA client memory registration

Hi-

Shirley Ma and I are reviving work on the NFS/RDMA client code base in the Linux kernel.  So far we've built and run functional tests to determine what is working and what is broken.

One complication is the number of memory registration modes supported by the RPC/RDMA transport: there are seven.  These were added over the years to support particular HCAs or as proof-of-concept.  The transport chooses a registration mode at mount time based on what the link HCA supports.

Not all HCAs support all memory registration modes, so our test matrix is quite large.  I'd like to propose removing support for one or more of these memory registration modes in the name of making it easier to change this code and test it without breaking something that we can't test.

BOUNCEBUFFERS - All HCAs support this mode.  Does not use RDMA READ and WRITE, and the client end copies data into place.  RDMA is offloaded, by data copy is not.  I'm told it was never intended for production use.

REGISTER - Safe but relatively slow.  Uses reg_phys_mr verb which is not supported in mlx4/mlx5, but all other HCAs/providers can use this mode.

MEM_WINDOWS - Uses bind_mr verb.  Safe, but supports only a narrow range of HCAs.

MEM_WINDOWS_ASYNC - Not always safe, and only a narrow range of HCAs is supported.

MTHCA_FMR - Uses alloc_fmr verb.  Safe, reasonably fast, but only a narrow range of older HCAs is supported.

FRMR - Safe, generally fast.  Currently the preferred registration mode, but is not supported with some older HCAs/providers.

ALLPHYSICAL - Usually fast, but not safe as it exposes client memory.  All HCAs support this mode.


I propose removing BOUNCEBUFFERS since it is not intended for production use.

I propose removing ALLPHYSICAL and MEM_WINDOWS_ASYNC as they are not generally safe.  RFC 5666 suggests that unsafe memory registration modes be avoided.

I propose removing MEM_WINDOWS as it adds complexity without adding a lot of HCA compatibility.

I propose removing MTHCA_FMR as I'm told it is hard to obtain HCAs we would need for testing this registration mode, and these are all old adapters anyway.

This leaves NFS/RDMA client support for REGISTER and FRMR, which should cover all existing HCAs, and it is easy to test both of these memory registration modes with just one or two well-picked HCAs.

We would contribute these changes to the client code base.  The NFS/RDMA server code could use similar attention, but we are not volunteering to change it at this time.
[sf] We need volunteers for server too as the optimizations on client only may not be enough considering that SMB express optimized both sides. Maybe we can find a student of Erez to work on this. Thanks

./Sorin 

Thoughts/comments?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html

