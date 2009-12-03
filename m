From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [pnfs] [PATCHSET 00/12 repost] nfsd: #includes cleanup
Date: Thu, 3 Dec 2009 14:01:06 -0500
Message-ID: <20091203190106.GB3317@fieldses.org>
References: <4B1802D0.8060206@panasas.com> <4B18054F.3080902@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756579AbZLCTAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Dec 2009 14:00:01 -0500
In-Reply-To: <4B18054F.3080902@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2009 at 08:37:03PM +0200, Boaz Harrosh wrote:
> On 12/03/2009 08:26 PM, Boaz Harrosh wrote:
> > 
> > Hi Bruce
> > 
> > I'm reposting the all set together
> > 
> > There are two patches that people have said will go through
> > other trees (see below). So either wait with patch 12/12 after
> > they get into Linus. Or also submit them through nfsd, it should
> > not cause any problems to post the same patch from two sub-trees,
> > right?
> > 
> > (For the things done here please let it sit in linux-next for
> >  a couple of nights)
> > 
> 
> Bruce, these are based on for-2.6.33 branch from your tree
> but I just realize that your "-next" branch is more advanced
> 
> Must I rebase? (But only Sunday it's getting late down here)

No, for-2.6.33 is the right one to work against.  Thanks!

(I'm keeping two main branches with pending patches:

	for-2.6.x: this is stuff I've committed.  I never rewind/rebase
	this branch.  This is almost always the branch to work against.

	for-2.6.x-next: this everything in for-2.6.x, plus stuff I'm
	expecting to commit soon, but may be waiting for review or may
	still need minor tweaks.  I may rewind this branch.  I wouldn't
	recommend working against it.  This is the branch that's pulled
	into linux-next.

)

--b.

> 
> Boaz
> > [PATCH 01/12] nfsd: Remove nfsfh.h dependency on sunrpc
> > [PATCH 02/12] sunrpc: Clean never used include files   
> > [PATCH 03/12] nfsd: Fix independence of a few nfsd related headers
> > [PATCH 04/12] nfsd: Headers Independence and include cleanups     
> > [PATCH 05/12] nfsd: Source files #include cleanups
> > 
> > 	First batch
> > 
> > [PATCH 06/12] compat.c: Remove dependence on nfsd private headers
> > [PATCH 07/12] parsic: remove un-used nfsd #includes
> > 
> > 	This patch we have ACK on
> > 
> > [PATCH 08/12] sparc: remove un-used nfsd #includes
> > [PATCH 09/12] s390: remove un-used nfsd #includes
> > 
> > 	These two were reported as submitted into ARCH tree for 2.6.33
> > 
> > [PATCH 10/12] lockd: Remove un-used nfsd headers #includes
> > [PATCH 11/12] vfs: nfsctl.c un-used nfsd #includes
> > 
> > [PATCH 12/12] nfsd: Move private headers to source directory
> > 	
> > 	this patch is the only one that depends on all
> > 	the other parts, and need all patches in.
> > 	(And will cause Benny's tree to adjust)
> > 
> > Thanks
> > Boaz
> > 
> > _______________________________________________
> > pNFS mailing list
> > pNFS@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
