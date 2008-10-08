From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 10/15] RPC/RDMA: return a consistent error to
  mount, when connect fails.
Date: Wed, 08 Oct 2008 15:56:49 -0400
Message-ID: <RTPCLUEXC1-PRD4ZDgC0000007e@RTPMVEXC1-PRD.hq.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
 <20081008154835.1336.85484.stgit@tmt3.nane.netapp.com>
 <1223487082.7361.17.camel@localhost>
 <RTPCLUEXC1-PRDbpH7100000075@RTPMVEXC1-PRD.hq.netapp.com>
 <1223487792.7361.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8177 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314AbYJHT5x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 15:57:53 -0400
In-Reply-To: <1223487792.7361.28.camel@localhost>
References: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <20081008154835.1336.85484.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <1223487082.7361.17.camel@localhost>
 <RTPCLUEXC1-PRDbpH7100000075-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <1223487792.7361.28.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:43 PM 10/8/2008, Trond Myklebust wrote:
>On Wed, 2008-10-08 at 13:40 -0400, Talpey, Thomas wrote:
>> At 01:31 PM 10/8/2008, Trond Myklebust wrote:
>> >On Wed, 2008-10-08 at 11:48 -0400, Tom Talpey wrote:
>> >> The mount system call path does not expect such errors as ECONNREFUSED
>> >> to be returned from failed transport connection attempts, otherwise it
>> >> prints simply "internal error". Translate all such errors to ENOTCONN
>> >> from RPC/RDMA to match sockets behavior.
>> >
>> >Hmm... Shouldn't we be passing the ECONNREFUSED error here, and rather
>> >fix the downstream error paths?
>> 
>> That means fixing /sbin/mount.nfs, and an earlier conversation concluded that
>> "doing what TCP does" was preferred. The error path from NFS and RPC is,
>> frankly, more than a little tortuous. The error is translated and filtered in
>> both layers, after being returned from the transport. Then, the mount command
>> makes up its own diagnostic from what comes back from the syscall. 
>Well beyond
>> the scope of RDMA.
>> 
>> Your call. As proposed, it is more compatible with current practice, IMO.
>
>Are you saying that mount.nfs translates 'ECONNREFUSED' as 'internal
>error'? That would be a bug...

No, unfortunately it's a good bit more complicated than that. Sorry for
oversimplifying. Mount.nfs would need to change, but the kernel too.

What happens is, the XYZ transport returns a connect status, which xprt.c's
xprt_connect_status() looks at and if non-zero decides what to dprintk, and
whether to retry.

xprt_connect_status() only parses two errors: ENOTCONN and ETIMEDOUT.
These result in various attempts to rebind and retry, as appropriate.
If any other error is returned, the status is changed to EIO and the call
is aborted. When the caller is mount, this results in EIO popping out of
the kernel as the return of sys_mount().

The EIO is then handled by mount.nfs in various unhelpful ways. Mount
pretty much never sees ECONNREFUSED from this call (though its userspace
stuff such as looking up ports and pinging servers does).

So, I just decided to return ENOTCONN like the other transports. I could
add new error arms to this code, but IMO they'd be unnecessary, for TCP
and UDP anyway.

Tom.

>
>Trond

