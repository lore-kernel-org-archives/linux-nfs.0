Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35725 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603Ab2AXXKK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 18:10:10 -0500
Date: Tue, 24 Jan 2012 18:10:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120124231009.GF12426@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327348867-699-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2012 at 03:01:01PM -0500, Jeff Layton wrote:
> - a number of the client_tracking functions have been changed to void
> return functions. Since the callers all ignore the return codes of those
> functions, there was little benefit in passing them back.

If you'd like to make that patch #1, I could apply it now.

--b.

> 
> Comments and suggestions are welcome...
> 
> Jeff Layton (6):
>   nfsd: add nfsd4_client_tracking_ops struct and a way to set it
>   sunrpc: create nfsd dir in rpc_pipefs
>   nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
>   nfsd: add a header describing upcall to nfsdcld
>   nfsd: add the infrastructure to handle the cld upcall
>   nfsd: get boot generation number from upcall instead of boot_time
> 
>  fs/nfsd/nfs4callback.c   |   12 +-
>  fs/nfsd/nfs4recover.c    |  480 +++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4state.c      |   63 +++----
>  fs/nfsd/state.h          |   22 ++-
>  include/linux/nfsd/cld.h |   58 ++++++
>  net/sunrpc/rpc_pipe.c    |    5 +
>  6 files changed, 581 insertions(+), 59 deletions(-)
>  create mode 100644 include/linux/nfsd/cld.h
> 
> -- 
> 1.7.7.5
> 
