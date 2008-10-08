From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 10/15] RPC/RDMA: return a consistent error to mount,
	when connect fails.
Date: Wed, 08 Oct 2008 13:43:12 -0400
Message-ID: <1223487792.7361.28.camel@localhost>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
	 <20081008154835.1336.85484.stgit@tmt3.nane.netapp.com>
	 <1223487082.7361.17.camel@localhost>
	 <RTPCLUEXC1-PRDbpH7100000075@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55265 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754571AbYJHRnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:43:16 -0400
In-Reply-To: <RTPCLUEXC1-PRDbpH7100000075-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-08 at 13:40 -0400, Talpey, Thomas wrote:
> At 01:31 PM 10/8/2008, Trond Myklebust wrote:
> >On Wed, 2008-10-08 at 11:48 -0400, Tom Talpey wrote:
> >> The mount system call path does not expect such errors as ECONNREFUSED
> >> to be returned from failed transport connection attempts, otherwise it
> >> prints simply "internal error". Translate all such errors to ENOTCONN
> >> from RPC/RDMA to match sockets behavior.
> >
> >Hmm... Shouldn't we be passing the ECONNREFUSED error here, and rather
> >fix the downstream error paths?
> 
> That means fixing /sbin/mount.nfs, and an earlier conversation concluded that
> "doing what TCP does" was preferred. The error path from NFS and RPC is,
> frankly, more than a little tortuous. The error is translated and filtered in
> both layers, after being returned from the transport. Then, the mount command
> makes up its own diagnostic from what comes back from the syscall. Well beyond
> the scope of RDMA.
> 
> Your call. As proposed, it is more compatible with current practice, IMO.

Are you saying that mount.nfs translates 'ECONNREFUSED' as 'internal
error'? That would be a bug...

Trond

