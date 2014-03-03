Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:18354 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbaCCRCh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 12:02:37 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
Date: Mon, 3 Mar 2014 12:02:33 -0500
Cc: Shirley Ma <shirley.ma@oracle.com>
Message-Id: <E755E683-C064-4ED3-8448-C61F4E5AF16E@oracle.com>
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
To: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2014, at 11:44 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

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
> 
> FRMR - Safe, generally fast.  Currently the preferred registration mode, but is not supported with some older HCAs/providers.
> 
> ALLPHYSICAL - Usually fast, but not safe as it exposes client memory.  All HCAs support this mode.
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

Karma score so far:

BOUNCEBUFFERS, REGISTER, MEM_WINDOWS, MEM_WINDOWS_ASYNC - no votes in favor of keeping

MTHCA_FMR, FRMR, ALLPHYSICAL - one or more votes in favor of keeping


All HCAs in 3.13 (and rxe) can support either MTHCA_FMR or FRMR or both. Wendy’s HCA supports only ALLPHYSICAL.

Does it make sense to deprecate then remove the registration modes in the first list?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



