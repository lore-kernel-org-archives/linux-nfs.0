From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [patch 0/4] correct kernel locking for RPC rpc_release
	callbacks
Date: Wed, 18 Oct 2006 16:22:03 -0400
Message-ID: <76bd70e30610181322j639e1ea9ifb5965cb61612934@mail.gmail.com>
References: <1161105870.3315.20.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaHvR-000398-Ms
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:22:05 -0700
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GaHvR-000567-6m
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:22:05 -0700
Received: by ug-out-1314.google.com with SMTP id p27so259176ugc
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 13:22:03 -0700 (PDT)
To: "Frank Filz" <ffilzlnx@us.ibm.com>
In-Reply-To: <1161105870.3315.20.camel@dyn9047022153>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 10/17/06, Frank Filz <ffilzlnx@us.ibm.com> wrote:
> The following set of patches corrects use of the big kernel lock in
> protecting RPC calls and associated call backs.
>
> A problem was noted where nfs_async_unlink_release() was called without
> the BKL being held as expected. Chuck Lever and Trond Myklebust noted
> that the rpc_release() callback is a recent addition and other callbacks
> might also expect the BKL to be held.
>
> With the addition of lock_kernel()/unlock_kernel() around all calls to
> the rpc_release() callbacks, there is no need for NFS code to hold the
> BKL when making calls to rpc_execute(), rpc_call_sync(), and
> rpc_call_async().

I spent a little time looking at these, and they look reasonable to
me.  I didn't see any paths that were now exposed by removing the BKL,
but I'm not the most rigorous reviewer.

I am a little concerned that the RPC scheduler is taking and dropping
such a heavy-weight serialization primitive multiple times per RPC.
Perhaps the next step should be removing the requirement for the
lock/unlock calls around the tk_action call to reduce this overhead.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
