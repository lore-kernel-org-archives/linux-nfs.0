Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33792 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751280AbdAMRI6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Jan 2017 12:08:58 -0500
Date: Fri, 13 Jan 2017 12:08:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 00/22] convert NFS server to new rdma_rw API
Message-ID: <20170113170849.GF24709@fieldses.org>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
 <20170113164208.GD24709@fieldses.org>
 <33FF9D08-075A-4153-ADDA-C460C1A4D93B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <33FF9D08-075A-4153-ADDA-C460C1A4D93B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 13, 2017 at 11:54:01AM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> 
> > On Jan 13, 2017, at 11:42 AM, bfields@fieldses.org wrote:
> > 
> > Can you summarize the motivation for the change, for someone (like me)
> > that doesn't know much about RDMA?  Or does "significant cleanups" cover
> > it?
> 
> Last year, Sagi and Christoph introduced a new set of APIs to the
> RDMA core that enable ULPs like iSER and NFS/RDMA to leave the details
> of certain aspects of operation to the core, instead of all the ULPs
> having to implement the details themselves. Kind of a code refactoring /
> de-duplication.
> 
> Then, going forward, fixes and improvements made to the logic behind
> this new API will be available to all ULPs that use the new API.
> 
> This series converts the server-side RPC-over-RDMA implementation
> to use the new API.
> 
> 
> > Are there any regressions?  For example, will it still support all the
> > same hardware?  Is there any change that will be noticeable to NFS/RDMA
> > users?
> 
> All the same hardware is supported. The standing policy for ULPs is
> that they must work with all in-tree HCA drivers and devices.
> 
> The goal of this work is that there is no user-visible change in
> functionality or performance.
> 
> I know it's a lot to consider, and I'm happy to split up the series
> or individual patches to help review.

Eh, I'll try to do a little, but realistically I'm mainly trusting you
and Christoph, so it's more important that the process work for you.

--b.
