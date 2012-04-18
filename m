Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:51277 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab2DRRuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2012 13:50:22 -0400
Date: Wed, 18 Apr 2012 18:50:19 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Message-ID: <20120418175019.GF3979@zeus>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
 <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 18, 2012 at 01:36:52PM -0400, Trond Myklebust wrote:
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
> -- 
> 1.7.7.6
> 
Great, thanks a lot.  I'll have this tested and let you know of the
results.

Cheers,
--
Luis
