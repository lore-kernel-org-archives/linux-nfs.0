Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45217 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab1E2I4z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 04:56:55 -0400
Message-ID: <4DE20A51.3030202@panasas.com>
Date: Sun, 29 May 2011 11:56:49 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCHSET v8 0/32] pnfs for 2.6.40
References: <4DDD7392.6040505@panasas.com>
In-Reply-To: <4DDD7392.6040505@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 12:24 AM, Benny Halevy wrote:
> Trond,
> 
> This patchset includes the latest fixes from Boaz and it is ready
> in my opinion for linux-next.
> 
> Last 5 patches include the changes we discussed for pg_test and
> their use by pnfs-obj, please review carefully.
> 
> Note that I skipped v7.  It was pushed up to the git tree but no patches were sent.
> 
> I released the series to git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfs-submit
> under this tag: pnfs-for-2.6.40-v8-2011-05-25
> 

Benny In your tree this patchset is based on *nfsd41-all* which is based on
nfsd-upstream which is based Linux 2.6.39. Each having one patch. I think these
two patches do not belong to this submit and should not go into linux next. They
should be moved up into the pnfsd-xxx part.

Thanks
Boaz

> Rebased on top of it are the pnfs-obj, pnfs, pnfsd-all, pnfsd-lexp-all,
> and pnfs-exofs-all branches, marked with tag pnfs-exofs-all-2.6.39-2011-05-25
> 
<snip>
