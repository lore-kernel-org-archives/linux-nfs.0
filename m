Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60117 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932646AbbGJTyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 15:54:15 -0400
Date: Fri, 10 Jul 2015 15:54:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V4 0/7] nfsd/sunrpc: prepare nfsd to add workqueue
 mode support
Message-ID: <20150710195414.GA7665@fieldses.org>
References: <5575E672.109@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5575E672.109@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 08, 2015 at 12:01:06PM -0700, Shirley Ma wrote:
> This patchset was originally written by Jeff Layton from adding support for a 
> workqueue-based nfsd. I am helping on stability test and performance analysis. 
> There are some workloads benefit from global threading mode, some workloads 
> benefit from workqueue mode. I am still investigating on how to make workqueue 
> mode better to bid global threading mode. I have split the original patchset 
> into two parts: one is preparing nfsd to add workqueue support, one is adding 
> workqueue mode. This is the first patchset, which doesn't impact nfsd threading 
> mode performance based upon my test results. These changes make nfsd threading 
> code more clean and easy to add workqueue mode in nfsd/sunrpc later.

Sorry for not reviewing more quickly.

I agree that this looks fine.  About half of it's justifiable just as
reasonable cleanup on its own.  The rest is adding some extra
indirection that isn't really needed yet, but it seems fairly minimal
and the workqueue stuff seems promising, so OK.

Applying for 4.3 pending some testing.  Branch for testing (which will
be rebased) here:

	git://linux-nfs.org/~bfields/linux.git nfsd-next

--b.

> 
> sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
> sunrpc: move sv_function into sv_ops
> sunrpc: move sv_module parm into sv_ops
> sunrpc: turn enqueueing a svc_xprt into a svc_serv operation
> sunrpc: abstract out svc_set_num_threads to sv_ops
> sunrpc: move pool_mode definitions into svc.h
> sunrpc: factor svc_rqst allocation and freeing from sv_nrthreads refcounting
> 
>  fs/lockd/svc.c                  |   7 ++-
>  fs/nfs/callback.c               |   6 ++-
>  fs/nfsd/nfssvc.c                |  17 ++++--
>  include/linux/sunrpc/svc.h      |  68 +++++++++++++++++-------
>  include/linux/sunrpc/svc_xprt.h |   1 +
>  net/sunrpc/svc.c                | 113 +++++++++++++++++++---------------------
>  net/sunrpc/svc_xprt.c           |  10 ++--
>  7 files changed, 135 insertions(+), 87 deletions(-)
