Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbaDZQnh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Apr 2014 12:43:37 -0400
Date: Sat, 26 Apr 2014 12:43:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, tom@ogc.us
Subject: Re: [PATCH] svcrdma: refactor marshalling logic
Message-ID: <20140426164336.GA11272@fieldses.org>
References: <20140410183723.29724.18665.stgit@build.ogc.int>
 <20140425105838.GE22295@fieldses.org>
 <6B12FA09-0E8C-497A-9145-E2B7CAB16C53@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6B12FA09-0E8C-497A-9145-E2B7CAB16C53@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2014 at 09:24:47AM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> On Apr 25, 2014, at 6:58 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Apr 10, 2014 at 01:37:23PM -0500, Steve Wise wrote:
> >> From: Tom Tucker <tom@ogc.us>
> >> 
> >> This patch refactors the marshalling logic to remove the intermediary
> >> map structures.  It also fixes an existing bug where the NFSRDMA server
> >> was not minding the device fast register page list length limitations.
> >> 
> >> Signed-off-by: Tom Tucker <tom@ogc.us>
> >> ---
> >> 
> >> include/linux/sunrpc/svc_rdma.h          |    3 
> >> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  551 +++++++++---------------------
> >> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  230 +------------
> >> net/sunrpc/xprtrdma/svc_rdma_transport.c |   57 ++-
> >> 4 files changed, 222 insertions(+), 619 deletions(-)
> > 
> > Is it possible to make this change in more than one step?
> > 
> > RDMA is pretty esoteric to most of us, so honestly this will probably
> > get merged based just on your having tested it, but if it was possible
> > to break this up into smaller patches you might give us at least a
> > fighting chance of giving it some review….
> 
> I agree it could be broken up.
> 
> However, my testing revealed that the patch inadvertently breaks support
> for HCAs that do not support FRMR.  I’ve reported this to Steve and Tom.
> IMO you should wait for a newer version of the refactoring patch.

Great, thanks, I'll wait.

> There are plenty of people who can review and test these patches.  We are
> working on setting up regular testing in a broad array of environments.
> 
> In general it would be best for maintainers not to merge NFS/RDMA patches
> at least until you see Tested-by and/or Reviewed-by on the mailing
> list.

(which note this had).

> I
> also thought it was appropriate to mail patches To: you when they are ready
> to be merged, but To: the mailing lists when asking for review.  Will that
> be a problem?

It'd be clearer to add an [RFC ...] or say clearly in the email that
it's not meant to be applied yet.

--b.
