Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:41897 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053Ab0EYM6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 08:58:32 -0400
Date: Tue, 25 May 2010 14:58:33 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Pavel Machek <pavel@ucw.cz>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        salvet@ics.muni.cz
Subject: Re: Deadlock in NFSv4 in all kernels
Message-ID: <20100525125833.GB9731@ics.muni.cz>
References: <20100507153920.GP28167@ics.muni.cz>
 <20100524212422.GA1286@ucw.cz>
 <1274790520.2949.20.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <1274790520.2949.20.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Tue, May 25, 2010 at 08:28:40AM -0400, Trond Myklebust wrote:
> > Seems like pretty fundamental problem in nfs :-(. Limiting writeback
> > caches for nfs, so that system has enough memory to perform rpc calls
> > with the rest might do the trick, but...
> > 
> 
> It's the same problem that you have for any file or storage system that
> has initiators in userland. On the storage side, iSCSI in particular has
> the same problem. On the filesystem side, CIFS, AFS, coda, .... do too.
> The clustered filesystems can deadlock if the node that is running the
> DLM runs out of memory...
> 
> A few years ago there were several people proposing various solutions
> for allowing these daemons to run in a protected memory environment to
> avoid deadlocks, but those efforts have since petered out. Perhaps it is
> time to review the problem?

I saw some patches targeting 2.6.35 that should prevent some deadlocks. They
seem to be not enough in some cases. rpc.* daemons should be mlocked for sure
but there is a problem with libkrb that reads files using fread(). fread() uses
anonymous mmap, under mlockall(MCL_FUTURE) this causes the anonymous map to be
mapped instantly and it deadlocks. 

IBM GPFS also uses userspace daemon, but it seems that the deamon is mlocked
and it does not open any files and does not create new connections. 

My problem was quite easily reproducible.

I started an application that eats 80% of free memory. Then I started:
for i in `seq 1 10`; do dd if=/dev/zero of=/mnt/nfs4/file$i bs=1M count=2048
& done

it deadlock within 2 minutes until this patch is applied:
commit 3d7b08945e54a3a5358d5890240619a013cb7388
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 22 15:35:55 2010 -0400

    SUNRPC: Fix a bug in rpcauth_prune_expired
    
    Don't want to evict a credential if cred->cr_expire == jiffies, since that
    means that it was just placed on the cred_unused list. We therefore need
to
    use time_in_range() rather than time_in_range_open().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index f394fc1..95afe79 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -237,7 +237,7 @@ rpcauth_prune_expired(struct list_head *free, int
nr_to_scan)
        list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
                /* Enforce a 60 second garbage collection moratorium */
-               if (time_in_range_open(cred->cr_expire, expired, jiffies) &&
+               if (time_in_range(cred->cr_expire, expired, jiffies) &&
                    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
                        continue;


but I believe this only hides the real problem.

-- 
Luká¹ Hejtmánek
