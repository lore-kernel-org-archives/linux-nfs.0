Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:35342 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751644Ab1HEN2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Aug 2011 09:28:25 -0400
Date: Fri, 5 Aug 2011 15:28:23 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
Message-ID: <20110805132823.GA32305@janus>
References: <20110804103018.GA11727@janus>
 <20110804163452.GE12445@fieldses.org>
 <20110804164313.GA17572@janus>
 <20110804164913.GG12445@fieldses.org>
 <1312477820.8919.5.camel@lade.trondhjem.org>
 <20110804172710.GB18087@janus>
 <1312481855.8919.20.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312481855.8919.20.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 04, 2011 at 02:17:35PM -0400, Trond Myklebust wrote:
> On Thu, 2011-08-04 at 19:27 +0200, Frank van Maarseveen wrote: 
> > On Thu, Aug 04, 2011 at 01:10:20PM -0400, Trond Myklebust wrote:
> > > On Thu, 2011-08-04 at 12:49 -0400, J. Bruce Fields wrote: 
> > > > On Thu, Aug 04, 2011 at 06:43:13PM +0200, Frank van Maarseveen wrote:
> > > > > On Thu, Aug 04, 2011 at 12:34:52PM -0400, J. Bruce Fields wrote:
> > > > > > On Thu, Aug 04, 2011 at 12:30:19PM +0200, Frank van Maarseveen wrote:
> > > > > > > Both client- and server run 2.6.39.3, NFSv3 over UDP (without the
> > > > > > > relock_filesystem patch proposed earlier).
> > > > > > > 
> > > > > > > A second client has an exclusive lock on a file on the server. The
> > > > > > > client under test calls fcntl(F_SETLKW) to wait for the same exclusive
> > > > > > > lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BLOCKED.
> > > > > > > 
> > > > > > > Next the server is rebooted. The second client recovers the lock
> > > > > > > correctly. The client under test now receives NLM_DENIED_GRACE_PERIOD for
> > > > > > > every NLM V4 LOCK request resulting from the waiting fcntl(F_SETLKW). When
> > > > > > > this changes to NLM_BLOCKED after grace period expiration the fcntl
> > > > > > > returns -ENOLCK ("No locks available.") instead of continuing to wait.
> > > > > > 
> > > > > > So that sounds like a client bug, and correct behavior from the server
> > > > > > (assuming the second client was still holding the lock throughout).
> > > > > 
> > > > > yes.
> > > 
> > > Is the client actually asking for a blocking lock after the grace period
> > > expires?
> > 
> > yes, according to my interpretation of that of wireshark, see reply to Bruce.
> > 
> 
> OK... Does the following patch help?
> 
> Cheers
>   Trond
> --- 
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index 8392cb8..40c0d88 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -270,6 +270,9 @@ nlmclnt_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 proc)
>  			return -ENOLCK;
>  		msg.rpc_proc = &clnt->cl_procinfo[proc];
>  
> +		/* Reset the reply status */
> +		if (argp->block)
> +			resp->status = nlm_lck_blocked;
>  		/* Perform the RPC call. If an error occurs, try again */
>  		if ((status = rpc_call_sync(clnt, &msg, 0)) < 0) {
>  			dprintk("lockd: rpc_call returned error %d\n", -status);
> 

Negative. I've tried it on the client under test and I'm seeing three
types of behavior, one good, two bad. In all cases the secondary
client (unmodified) correctly regains the lock after the server has
rebooted. Client under test behavior depends on whether it had queued
the conflicting lock before of after the server reboot. Afterwards it
seems to work with the above modification (don't know if that was the
case before though).

When the client under test tries to lock before the server reboot then
the fcntl(F_SETLKW) returns either right after the NSM NOTIFY with
-ENOLCK without any NLM trafic or it returns with -ENOLCK when the
NLM_DENIED_GRACE_PERIOD changes into NLM_BLOCKED (the original report).

-- 
Frank
