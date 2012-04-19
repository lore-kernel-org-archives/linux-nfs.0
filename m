Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:55092 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467Ab2DSNtB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 09:49:01 -0400
Date: Thu, 19 Apr 2012 14:48:47 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Message-ID: <20120419134847.GC2916@zeus>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
 <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120419093025.GA2916@zeus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120419093025.GA2916@zeus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 19, 2012 at 10:30:25AM +0100, Luis Henriques wrote:
> On Wed, Apr 18, 2012 at 01:36:52PM -0400, Trond Myklebust wrote:
> > The first patch addresses the Oops.
> > The second will hopefully address the looping.
> > 
> > Trond Myklebust (2):
> >   NFSv4: Ensure that the LOCK code sets exception->inode
> >   NFSv4: Ensure that we check lock exclusive/shared type against open
> >     modes
> > 
> >  fs/nfs/nfs4proc.c |   23 +++++++++++++++++++++--
> >  1 files changed, 21 insertions(+), 2 deletions(-)
> > 
> > -- 
> > 1.7.7.6
> > 
> Just to let you know we do have a few successful tests on these patches.
> You can check the details here:
> 
> http://bugs.launchpad.net/bugs/974664
> 
> Although I haven't tested the patches myself, fell free to add a Tested-by
> to these patches.

There's something else a forgot to mention, which is the fact that the bug
reports were for kernel 3.2.14.  So you may want to update the
"Cc: stable@vger.kernel.org" on commit 487790f27df9bb27d3400486bd021dd59edc7589
to include at least this version.

There are two another patches we have applied that are present in mainline
but haven't made its way into stable:
 - 14977489ffdb80d4caf5a184ba41b23b02fbacd9
 - 96dcadc2fdd111dca90d559f189a30c65394451a

Cheers,
--
Luis
