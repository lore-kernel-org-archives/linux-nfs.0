Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50380 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab3IJVze (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 17:55:34 -0400
Date: Tue, 10 Sep 2013 17:55:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joschi Brauchle <joschi.brauchle@tum.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd4: utime sometimes takes 40+ seconds to return (but on
 SLES11SP3 with kernel 3.0.82)
Message-ID: <20130910215534.GA21829@fieldses.org>
References: <522F69A1.5090005@tum.de>
 <20130910203530.GA20296@fieldses.org>
 <038EA8B0-BD46-47F2-8F20-DEC8B6DA9087@tum.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <038EA8B0-BD46-47F2-8F20-DEC8B6DA9087@tum.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 10, 2013 at 09:48:12PM +0000, Joschi Brauchle wrote:
> Am 10.09.2013 um 22:35 schrieb "J. Bruce Fields" <bfields@fieldses.org>:
> 
> > On Tue, Sep 10, 2013 at 08:49:05PM +0200, Joschi Brauchle wrote:
> >> Hello everyone,
> >> 
> >> we are administrating an NFS high-availability cluster running on
> >> SLES11SP1 with kernel 2.6.32.59. Just recently, one of the cluster
> >> machines was updated to SLES11SP3 with kernel 3.0.82.
> >> 
> >> 
> >> We are now experiencing severe hangs on NFS clients when the
> >> SLES11SP3 server is running the NFS services. An strace on the
> >> hanging processes on the client side show that is is waiting up to
> >> 60+ seconds for a "utime()" call to complete.
> >> 
> >> 
> >> The problem we see is matching the problem described in the thread
> >> "v3.5 nfsd4 regression; utime sometimes takes 40+ seconds to
> >> return". If the NFS server is running on SLES11SP3, the little test
> >> program provided in this tread hangs at the "utime()" call for 60+
> >> seconds. It hangs each time it is run! It finishes right away with 0
> >> seconds delay is SLES11SP1 is providing NFS services, each time.
> >> 
> >> 
> >> Now, in the serverside logfiles of SLES11SP3 we see these messages
> >> (not so on SP1):
> >> --------------
> >> kernel: [99381.184976] RPC: AUTH_GSS upcall timed out.
> >> kernel: [99381.184978] Please check user daemon is running.
> >> --------------
> >> 
> >> We have always been running the NFS server without rpc.gssd on the
> >> server side, as the init script for the nfsserver also does not
> >> start rpc.gssd.
> >> 
> >> 
> >> Once we started rpc.gssd on the SLES11SP3 server, using the test
> >> utility on the client shows that the first call to "utime()"
> >> succeeds right away, the second call takes ~25s to complete. But
> >> now, any consecutive runs of the utility finish with no more delay.
> >> 
> >> 
> >> So can anyone confirm that with kernel 3.0+ the rpc.gssd daemon is
> >> also required on the server side for correct operation?
> >> 
> >> Has there been a change between kernel 2.6.32.59 and 3.0.x?
> >> 
> >> Thus, is the init script of the nfsserver in SLES11SP3 indeed
> >> missing to start rpc.gssd?
> > 
> > It should be starting rpc.gssd to allow callbacks, yes.
> > 
> > --b.
> 
> Ok, we will run rpc.gssd on the server. Thanks. 
> 
> Could you please comment on having the nfs clients hang on utime() calls is to be expected when *not* running rpc.gssd? Or is this a problem that needs to be investigated?

I think what happens is the utime call breaks a delegation, and the
delay is because the lack of gssd prevents the server from calling back
to the client to tell it that its delegation is broken, so the
delegation has to time out.

That said, the server does a null callback to the client to test whether
callbacks are working before it gives out any delegations, so I'm
surprised it wouldn't have noticed the broken callbacks then.

--b.
