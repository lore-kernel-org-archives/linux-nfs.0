Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51266 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750790AbeAPVdo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Jan 2018 16:33:44 -0500
Date: Tue, 16 Jan 2018 16:33:43 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] NFS/RDMA server changes for v4.16
Message-ID: <20180116213343.GD21173@fieldses.org>
References: <20180103203849.7074.9609.stgit@klimt.1015granger.net>
 <BD4AB89D-D4A5-4576-A9EE-4D0A485F13E1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BD4AB89D-D4A5-4576-A9EE-4D0A485F13E1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 16, 2018 at 04:31:07PM -0500, Chuck Lever wrote:
> 
> 
> > On Jan 3, 2018, at 3:42 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > Hi Bruce-
> > 
> > Would you consider these patches for merging into v4.16?
> 
> Hi Bruce, since you haven't responded, I assume these will
> not appear in v4.16. Let's drop these for now, and I will
> resubmit them for v4.17.

Sorry for the lack of response, I started reviewing but didn't finish,
and still expect to get them in for 4.16.

--b.

> 
> 
> > Changes since v1:
> > - Rebased on v4.15-rc6
> > - Address a 0day robot complaint in nfsd3_proc_symlink
> > - Properly handle error return from svc_rdma_handle_bc_reply
> > 
> > ---
> > 
> > Chuck Lever (3):
> >      svcrdma: Post Receives in the Receive completion handler
> >      NFSD: Clean up write argument XDR decoders
> >      NFSD: Clean up symlink argument XDR decoders
> > 
> > 
> > fs/nfsd/nfs3proc.c                         |   18 ++++-
> > fs/nfsd/nfs3xdr.c                          |   67 ++++-------------
> > fs/nfsd/nfs4proc.c                         |   37 +++-------
> > fs/nfsd/nfs4xdr.c                          |   11 ++-
> > fs/nfsd/nfsproc.c                          |   23 ++++--
> > fs/nfsd/nfsxdr.c                           |   63 ++++++++--------
> > fs/nfsd/xdr.h                              |    3 +
> > fs/nfsd/xdr3.h                             |    3 +
> > fs/nfsd/xdr4.h                             |    3 +
> > include/linux/sunrpc/svc.h                 |    4 +
> > include/linux/sunrpc/svc_rdma.h            |    2 -
> > net/sunrpc/svc.c                           |  109 ++++++++++++++++++++++++++++
> > net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    5 -
> > net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    9 --
> > net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    6 --
> > net/sunrpc/xprtrdma/svc_rdma_transport.c   |   25 ++----
> > 16 files changed, 225 insertions(+), 163 deletions(-)
> > 
> > --
> > Chuck Lever
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
