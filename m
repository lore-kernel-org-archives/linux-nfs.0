Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35437 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756127Ab2IQPBH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 11:01:07 -0400
Date: Mon, 17 Sep 2012 11:01:05 -0400
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org, bfields@redhat.com,
        viro@zeniv.linux.org.uk, jbottomley@parallels.com
Subject: Re: [PATCH 0/2] nfsd: backport fixes for 3.5 kernel
Message-ID: <20120917150105.GJ30673@fieldses.org>
References: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 14, 2012 at 12:25:17PM +0400, Stanislav Kinsbursky wrote:
> Hello.
> These two patches fixes existent NULL pointer dereference problem in 3.5.3
> kernel in case of some error occured during NFSd service start.
> 
> Upstream commits:
> 19f7e2ca44dfc3c1b3f499fc46801f98d403500f 
> 57c8b13e3cd0f94944c9691ce7f58e5fcef8a12d

Thanks.  Ack to including both of these in stable releases.

--b.

> 
> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (2):
>       NFSd: introduce nfsd_destroy() helper
>       NFSd: set nfsd_serv to NULL after service destruction
> 
> 
>  fs/nfsd/nfsctl.c |    8 ++------
>  fs/nfsd/nfsd.h   |   11 +++++++++++
>  fs/nfsd/nfssvc.c |   24 ++++++++----------------
>  3 files changed, 21 insertions(+), 22 deletions(-)
> 
