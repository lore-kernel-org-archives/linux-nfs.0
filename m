From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Thu, 19 Jun 2008 08:14:20 -0400
Message-ID: <20080619081420.24645bc4@tleilax.poochiereds.net>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	<76bd70e30806041643j4d632a6exf64b29c34173d40f@mail.gmail.com>
	<6278d2220806151110x68ee91fej8cf8e6b591ce1319@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/U/DoluFDvqRBTSZcdRtSHDG"
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, "Linux Kernel" <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994AbYFSMO2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 08:14:28 -0400
In-Reply-To: <6278d2220806151110x68ee91fej8cf8e6b591ce1319-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/U/DoluFDvqRBTSZcdRtSHDG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sun, 15 Jun 2008 19:10:27 +0100
"Daniel J Blueman" <daniel.blueman@gmail.com> wrote:

> On Thu, Jun 5, 2008 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > Hi Daniel-
> >
> > On Wed, Jun 4, 2008 at 7:33 PM, Daniel J Blueman
> > <daniel.blueman@gmail.com> wrote:
> >> Having experienced 'mount.nfs4: internal error' when mounting nfsv4 in
> >> the past, I have a minimal test-case I sometimes run:
> >>
> >> $ while :; do mount -t nfs4 filer:/store /store; umount /store; done
> >>
> >> After ~100 iterations, I saw the 'mount.nfs4: internal error',
> >> followed by symptoms of memory corruption [1], a locking issue with
> >> the reporting [2] and another (related?) memory-corruption issue
> >> (off-by-1?) [3]. A little analysis shows memory being overwritten by
> >> (likely) a poison value, which gets complicated if it's not
> >> use-after-free...
> >>
> >> Anyone dare confirm this issue? NFSv4 server is x86-64 Ubuntu 8.04
> >> 2.6.24-18, client U8.04 2.6.26-rc4; batteries included [4].
> >
> > We have some other reports of late model kernels with memory
> > corruption issues during NFS mount.  The problem is that by the time
> > these canaries start singing, the evidence of what did the corrupting
> > is long gone.
> >
> >> I'm happy to decode addresses, test patches etc.
> >
> > If these crashes are more or less reliably reproduced, it would be
> > helpful if you could do a 'git bisect' on the client to figure out at
> > what point in the kernel revision history this problem was introduced.
> >
> > Have you seen the problem on client kernels earlier than 2.6.25?
> 
> Firstly, I had omitted that I'd booted the kernel with
> debug_objects=1, which provides the canary here.
> 
> The primary failure I see is 'mount.nfs4: internal error', and always
> after 358 umount/mount cycles (plus 1 initial mount) which gives us a
> clue; 'netstat' shows all these connections in a TIME_WAIT state, thus
> the bug relates to the inability to allocate a socket error path. I
> found that after the connection lifetime expired, you can mount again,
> which corroborates this theory.
> 
> In this case, we saw the mount() syscall result in the mount.nfsv4
> process being SEGV'd when booted with 'debug_object=1', without this
> option, we see:
> 
> # strace /sbin/mount.nfs4 x1:/ /store
> ...
> mount("x1:/", "/store", "nfs4", 0,
> "addr=192.168.0.250,clientaddr=19"...) = -1 EIO (Input/output error)
> 
> So, it's impossible to tell when the corruption was introduced, as it
> has only become detectable recently.
> 
> It's worth a look-over of the socket-allocation error path, if someone
> can check, and reproduces 100% with the 'debug_object=1' param,
> available since 2.6.26-rc1 and 359 mounts in quick succession.
> 

For some strange reason (probably something I'm doing wrong or maybe
something environmental), I've not been able to reproduce this panic on
a stock kernel. I did, however, apply the following fault injection
patch and was able to reproduce it on the second mount attempt. The 3
patch set that I posted last week definitely prevents the oops. If
you're able to confirm that it also fixes your panic it would be a
helpful data point.

The fault injection patch I'm using is attached. It just simulates
nfs4_init_client() consistently returning an error.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>

--MP_/U/DoluFDvqRBTSZcdRtSHDG
Content-Type: text/x-patch; name=nfs4-mount-fault-injection.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=nfs4-mount-fault-injection.patch

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f2a092c..5ff4e46 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1028,8 +1028,11 @@ static int nfs4_set_client(struct nfs_server *server,
 		error = PTR_ERR(clp);
 		goto error;
 	}
+	error = -ENOMEM;
+/*
 	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour);
 	if (error < 0)
+*/
 		goto error_put;
 
 	server->nfs_client = clp;

--MP_/U/DoluFDvqRBTSZcdRtSHDG--
