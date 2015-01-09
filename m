Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37334 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969AbbAIUo7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2015 15:44:59 -0500
Date: Fri, 9 Jan 2015 15:44:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 00/10] NFS/RDMA server for 3.20
Message-ID: <20150109204458.GC30452@fieldses.org>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
 <20150109203958.GB30452@fieldses.org>
 <629A4CE4-ECB9-4A1D-9179-CFAD2FC7AD91@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <629A4CE4-ECB9-4A1D-9179-CFAD2FC7AD91@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 03:40:51PM -0500, Chuck Lever wrote:
> 
> On Jan 9, 2015, at 3:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Fri, Jan 09, 2015 at 02:21:54PM -0500, Chuck Lever wrote:
> >> In addition to miscellaneous clean up, the following series of
> >> patches for the Linux NFS server introduces support in the
> >> server’s RPC/RDMA transport implementation for RDMA_NOMSG type
> >> messages, and fixes a bug that prevents the server from handling
> >> RPC/RDMA messages with inline content following a read list.
> >> 
> >> These patches are contained in the branch "nfsd-rdma-for-3.20" at:
> >> 
> >>  git://git.linux-nfs.org/projects/cel/cel-2.6.git
> > 
> > They look OK to me; applying unless someone tells me otherwise.
> 
> I’d like to update the patch descriptions in several of these before
> you apply the series.

OK, let me know.--b.

> 
> > 
> > --b.
> > 
> >> 
> >> ---
> >> 
> >> Chuck Lever (10):
> >>      svcrdma: Handle additional inline content
> >>      Move read list XDR round-up logic
> >>      svcrdma: Support RDMA_NOMSG requests
> >>      svcrdma: rc_position sanity checking
> >>      svcrdma: Plant reader function in struct svcxprt_rdma
> >>      svcrdma: Find rmsgp more reliably
> >>      svcrdma: Scrub BUG_ON() and WARN_ON() call sites
> >>      svcrdma: Clean up read chunk counting
> >>      svcrdma: Remove unused variable
> >>      svcrdma: Clean up dprintk
> >> 
> >> 
> >> include/linux/sunrpc/svc_rdma.h          |   13 +-
> >> net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   16 --
> >> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  251 +++++++++++++++++++-----------
> >> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   46 +++--
> >> net/sunrpc/xprtrdma/svc_rdma_transport.c |   47 +++---
> >> 5 files changed, 224 insertions(+), 149 deletions(-)
> >> 
> >> --
> >> Chuck Lever
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
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
