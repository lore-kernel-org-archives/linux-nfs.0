From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 15:24:11 -0500
Message-ID: <1234470251.7190.102.camel@heimdal.trondhjem.org>
References: <20090211112318.GA29133@janus>
	 <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus>
	 <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus>
	 <1234451789.7190.38.camel@heimdal.trondhjem.org>
	 <20090212153634.GB28107@janus>
	 <1234462647.7190.53.camel@heimdal.trondhjem.org>
	 <20090212182943.GA1945@janus>
	 <1234465837.7190.62.camel@heimdal.trondhjem.org>
	 <20090212191607.GA3108@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55363 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758734AbZBLUYS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2009 15:24:18 -0500
In-Reply-To: <20090212191607.GA3108@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-12 at 20:16 +0100, Frank van Maarseveen wrote:
> On Thu, Feb 12, 2009 at 02:10:37PM -0500, Trond Myklebust wrote:
> > On Thu, 2009-02-12 at 19:29 +0100, Frank van Maarseveen wrote:
> > > On Thu, Feb 12, 2009 at 01:17:27PM -0500, Trond Myklebust wrote:
> > > > On Thu, 2009-02-12 at 16:36 +0100, Frank van Maarseveen wrote:
> > > > > A little theorizing:
> > > > > If the unlock of a yet unrecovered lock has failed up to that point then
> > > > > the client sure must remember the lock somehow. That might explain the
> > > > > secondary error when a conflicting lock is granted by the server.
> > > > 
> > > > Sorry, but that doesn't hold water. The client will release the VFS
> > > > 'mirror' of the lock before it attempts to unlock. Otherwise, you could
> > > > have some nasty races between the unlock thread and the recovery
> > > > thread...
> > > > Besides, the granted callback handler on the client only checks the list
> > > > of blocked locks for a match.
> > > 
> > > ok, then we have more than one NLM bug to resolve.
> > > 
> > > > 
> > > > Oh, bugger, I know what this is... It's the same thing that happened to
> > > > the NFSv4 callback server. If you compile with CONFIG_IPV6 or
> > > > CONFIG_IPV6_MODULE enabled, and also set CONFIG_SUNRPC_REGISTER_V4, then
> > > > the NLM server will listen on an IPv6 socket, and so the RPC request
> > > > come in with their IPv4 address mapped into the IPv6 namespace.
> > > 
> > > Nope:
> > > 
> > > 	$ zgrep IPV6 /proc/config.gz 
> > > 	# CONFIG_IPV6 is not set
> > > 	$ zgrep SUNRPC /proc/config.gz 
> > > 	CONFIG_SUNRPC=y
> > > 	CONFIG_SUNRPC_GSS=y
> > > 	# CONFIG_SUNRPC_BIND34 is not set
> > 
> > Sorry, yes... 2.6.27.x should be OK. The lockd v4mapped addresses bug is
> > specific to 2.6.29. Chuck, are you planning on fixing this before
> > 2.6.29-final comes out?
> > 
> > > And remember this is not a recent regression.
> > 
> > It would help if you sent us the full binary tcpdump, instead of just
> > the summary. That should enable us to figure out which of the tests is
> > failing in nlmclnt_grant().
> 
> I posted the link already. Anyway, see attachment.

Yeah... It looks alright. The one thing that looks a bit odd is the
GRANTED lock has a 'caller_name' field that is set to the name of the
server. I pretty sure we don't care about that, though...

Hmm... I wonder if the problem isn't just that we're failing to cancel
the lock request when the process is signalled. Can you try the
following patch?

--------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
NLM/lockd: Always cancel blocked locks when exiting early from nlmclnt_lock

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)


diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 31668b6..f956d1e 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -542,9 +542,14 @@ again:
 		status = nlmclnt_call(cred, req, NLMPROC_LOCK);
 		if (status < 0)
 			break;
-		/* Did a reclaimer thread notify us of a server reboot? */
-		if (resp->status ==  nlm_lck_denied_grace_period)
+		/* Is the server in a grace period state?
+		 * If so, we need to reset the resp->status, and
+		 * retry...
+		 */
+		if (resp->status ==  nlm_lck_denied_grace_period) {
+			resp->status = nlm_lck_blocked;
 			continue;
+		}
 		if (resp->status != nlm_lck_blocked)
 			break;
 		/* Wait on an NLM blocking lock */


