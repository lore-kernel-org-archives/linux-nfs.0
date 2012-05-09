Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab2EITI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 15:08:57 -0400
Date: Wed, 9 May 2012 15:08:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/6] Lockd: service start cleanup patch set
Message-ID: <20120509190855.GB27077@fieldses.org>
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 25, 2012 at 06:22:32PM +0400, Stanislav Kinsbursky wrote:
> This patch set simplifies LockD start logic, makes code looks straight-forward
> and clear.

I've applied and pushed these out.

I believe I now have everything from you except your latest grace-period
handling rfc.  Could you check and make sure that I'm not missing
anything else, and that I haven't messed up anything else?

--b.

> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (6):
>       LockD: pass service to per-net up and down functions
>       LockD: use existent per-net data function on service creation
>       LockD: service creation function introduced
>       LockD: move global usage counter manipulation from error path
>       LockD: service start function introduced
>       LockD: add debug message to start and stop functions
> 
> 
>  fs/lockd/svc.c |  140 +++++++++++++++++++++++++++++++++-----------------------
>  1 files changed, 83 insertions(+), 57 deletions(-)
> 
