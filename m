Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:53755 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab2DSJah (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 05:30:37 -0400
Date: Thu, 19 Apr 2012 10:30:25 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Message-ID: <20120419093025.GA2916@zeus>
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
Just to let you know we do have a few successful tests on these patches.
You can check the details here:

http://bugs.launchpad.net/bugs/974664

Although I haven't tested the patches myself, fell free to add a Tested-by
to these patches.

Cheers,
--
Luis
