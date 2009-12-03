From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCHSET 00/12 repost] nfsd: #includes cleanup
Date: Thu, 03 Dec 2009 20:37:03 +0200
Message-ID: <4B18054F.3080902@panasas.com>
References: <4B1802D0.8060206@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59322 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756023AbZLCSg6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:36:58 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/03/2009 08:26 PM, Boaz Harrosh wrote:
> 
> Hi Bruce
> 
> I'm reposting the all set together
> 
> There are two patches that people have said will go through
> other trees (see below). So either wait with patch 12/12 after
> they get into Linus. Or also submit them through nfsd, it should
> not cause any problems to post the same patch from two sub-trees,
> right?
> 
> (For the things done here please let it sit in linux-next for
>  a couple of nights)
> 

Bruce, these are based on for-2.6.33 branch from your tree
but I just realize that your "-next" branch is more advanced

Must I rebase? (But only Sunday it's getting late down here)

Boaz
> [PATCH 01/12] nfsd: Remove nfsfh.h dependency on sunrpc
> [PATCH 02/12] sunrpc: Clean never used include files   
> [PATCH 03/12] nfsd: Fix independence of a few nfsd related headers
> [PATCH 04/12] nfsd: Headers Independence and include cleanups     
> [PATCH 05/12] nfsd: Source files #include cleanups
> 
> 	First batch
> 
> [PATCH 06/12] compat.c: Remove dependence on nfsd private headers
> [PATCH 07/12] parsic: remove un-used nfsd #includes
> 
> 	This patch we have ACK on
> 
> [PATCH 08/12] sparc: remove un-used nfsd #includes
> [PATCH 09/12] s390: remove un-used nfsd #includes
> 
> 	These two were reported as submitted into ARCH tree for 2.6.33
> 
> [PATCH 10/12] lockd: Remove un-used nfsd headers #includes
> [PATCH 11/12] vfs: nfsctl.c un-used nfsd #includes
> 
> [PATCH 12/12] nfsd: Move private headers to source directory
> 	
> 	this patch is the only one that depends on all
> 	the other parts, and need all patches in.
> 	(And will cause Benny's tree to adjust)
> 
> Thanks
> Boaz
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

