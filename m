Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27311 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486Ab3ECQSG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2013 12:18:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.x: Fix handling of partially delegated locks
Date: Fri, 3 May 2013 16:18:03 +0000
Message-ID: <1367597884.3556.6.camel@leira.trondhjem.org>
References: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com>
	 <9873A24B-BCB9-4F95-9EC7-0DE38513505D@oracle.com>
In-Reply-To: <9873A24B-BCB9-4F95-9EC7-0DE38513505D@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-05-03 at 12:12 -0400, Chuck Lever wrote:
> Hi-
> 
> On May 2, 2013, at 1:19 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > If a NFS client receives a delegation for a file after it has taken
> > a lock on that file, we can currently end up in a situation where
> > we mistakenly skip unlocking that file.
> > 
> > The following patch swaps an erroneous check in nfs4_proc_unlck for
> > whether or not the file has a delegation to one which checks whether
> > or not we hold a lock stateid for that file.
> > 
> > Reported-by: Chuck Lever <Chuck.Lever@oracle.com>
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Cc: stable@vger.kernel.org
> 
> Although this patch may apply cleanly to, say, 3.0-stable, the result is that LOCKUs now never appear on the wire.  It seems that older stable kernels are missing something that is needed to make this simple fix work correctly.

Yes. There is a dependency on commit
795a88c968eef031f370973512b42124bacb2f17 (NFSv4: Convert the
nfs4_lock_state->ls_flags to a bit field).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
