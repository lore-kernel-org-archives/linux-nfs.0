From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] nfsd: fix error handling in write_ports interfaces
Date: Tue, 8 Jun 2010 20:00:03 -0400
Message-ID: <20100609000002.GL26435@fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34734 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963Ab0FIAAJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 20:00:09 -0400
In-Reply-To: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 07, 2010 at 11:33:17AM -0400, Jeff Layton wrote:
> This patchset fixes some problems with refcounting when there are
> problems starting up nfsd. The easiest way to reproduce this is to have
> rpcbind down and then try to start nfsd. The write_ports calls will
> generally return failure at that point due to the fact that lockd can't
> register its ports. That leaves the nfsd_serv pointer set, with the
> sv_threads count set at 0. The first two patches fix this problem.

Does this look like it's always been a problem, or was it introduced by
recent changes?

(Just a question of priority and whether it should be fixed in -stable
branches too.)

--b.

> 
> The third patch, I'm not 100% sure on. It looks correct to me, but the
> intent of the existing code is not very clear. I know this interface is
> used by the rdma code, and I may be missing the point of doing it this
> way. If the existing code is correct as-is, I'll plan to do a patch to
> add some clarifying comments.
> 
> It also seems suspicious to me that __write_ports_addfd/delfd take and
> put lockd references, but the addxprt/delxprt interfaces do not. If
> someone were to addfd a socket and then delxprt it, it'll leave a lockd
> reference dangling.
> 
> Should we be taking and putting lockd references in those codepaths as
> well?
> 
> Jeff Layton (3):
>   nfsd: don't try to shut down nfs4 state handling unless it's up
>   nfsd: fix error handling when starting nfsd with rpcbind down
>   nfsd: fix error handling in __write_ports_addxprt
> 
>  fs/nfsd/nfs4state.c |    2 ++
>  fs/nfsd/nfsctl.c    |   18 ++++++++++++------
>  2 files changed, 14 insertions(+), 6 deletions(-)
> 
