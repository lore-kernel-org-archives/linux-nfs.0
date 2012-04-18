Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab2DRRmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:42:05 -0400
Date: Wed, 18 Apr 2012 13:42:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Luis Henriques <luis.henriques@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Message-ID: <20120418134254.08dd8422@corrin.poochiereds.net>
In-Reply-To: <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
	<1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Apr 2012 13:36:52 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> The first patch addresses the Oops.
> The second will hopefully address the looping.
> 
> Trond Myklebust (2):
>   NFSv4: Ensure that the LOCK code sets exception->inode
>   NFSv4: Ensure that we check lock exclusive/shared type against open
>     modes
> 
>  fs/nfs/nfs4proc.c |   23 +++++++++++++++++++++--
>  1 files changed, 21 insertions(+), 2 deletions(-)
> 


ACK. Looks like the best way to handle this...

I wonder though whether we should also push 14977489 to stable as well.

While we expect NFS4ERR_OPENMODE from these codepaths, it's possible
that we could get that in others when we don't expect it (from a
misbehaving server perhaps?). That could cause an oops since we're not
checking for a NULL inode in nfs4_handle_exception currently in 3.3.x
kernels.

-- 
Jeff Layton <jlayton@redhat.com>
