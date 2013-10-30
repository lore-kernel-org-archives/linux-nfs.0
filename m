Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36241 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590Ab3J3PMp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Oct 2013 11:12:45 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] - hard-to-hit race in xprtsock.
Date: Wed, 30 Oct 2013 15:12:41 +0000
Message-ID: <1383145958.6287.0.camel@leira.trondhjem.org>
References: <20131029174204.7f6578d4@notabene.brown>
	 <1383058955.7805.2.camel@leira.trondhjem.org>
	 <20131030170250.702da2c3@notabene.brown>
In-Reply-To: <20131030170250.702da2c3@notabene.brown>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-10-30 at 17:02 +-1100, NeilBrown wrote:
+AD4- On Tue, 29 Oct 2013 15:02:36 +-0000 +ACI-Myklebust, Trond+ACI-
+AD4- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Tue, 2013-10-29 at 17:42 +-1100, NeilBrown wrote:
+AD4- +AD4- +AD4- We have a customer who hit a rare race in sunrpc (in a 3.0 based kernel,
+AD4- +AD4- +AD4- but the relevant code doesn't seem to have changed much).
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- The thread that crashed was in 
+AD4- +AD4- +AD4-   xs+AF8-tcp+AF8-setup+AF8-socket -+AD4- inet+AF8-stream+AF8-connect -+AD4- lock+AF8-sock+AF8-nested.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- 'sock' in this last function is NULL.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- The only way I can imagine this happening is if some other thread called
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4-  xs+AF8-close -+AD4- xs+AF8-reset+AF8-transport -+AD4- sock+AF8-release -+AD4- inet+AF8-release
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- in a very small window a moment earlier.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- As far as I can tell, xs+AF8-close is only called with XPRT+AF8-LOCKED set.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- xs+AF8-tcp+AF8-setup+AF8-socket is mostly scheduled with XPRT+AF8-LOCKED set to which would
+AD4- +AD4- +AD4- exclude them from running at the same time.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- However xs+AF8-tcp+AF8-schedule+AF8-linger+AF8-timeout can schedule the thread which runs
+AD4- +AD4- +AD4- xs+AF8-tcp+AF8-setup+AF8-socket without first claiming XPRT+AF8-LOCKED.
+AD4- +AD4- +AD4- So I assume that is what is happening.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- I imagine some race between the client closing the socket, and getting
+AD4- +AD4- +AD4- TCP+AF8-FIN+AF8-WAIT1 from the server and somehow the two threads racing.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- I wonder if it might make sense to always abort 'connect+AF8-worker' in
+AD4- +AD4- +AD4- xs+AF8-close()?
+AD4- +AD4- +AD4- I think the connect+AF8-worker really mustn't be running or queued at this point,
+AD4- +AD4- +AD4- so cancelling it is either a no-op, or vitally important.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- So: does the following patch seem reasonable?  If so I'll submit it properly
+AD4- +AD4- +AD4- with a coherent description etc.
+AD4- +AD4- 
+AD4- +AD4- Hi Neil,
+AD4- +AD4- 
+AD4- +AD4- Will that do the right thing if the connect+AF8-worker and close are running
+AD4- +AD4- on the same rpciod thread? I think it should, but I never manage to keep
+AD4- +AD4- 100+ACU- up to date with the ever changing semantics of
+AD4- +AD4- cancel+AF8-delayed+AF8-work+AF8-sync() and friends...
+AD4- +AD4- 
+AD4- +AD4- Cheers,
+AD4- +AD4-   Trond
+AD4- 
+AD4- Thanks for asking that+ACE-  I had the exact same concern when I first conceived
+AD4- the patch.
+AD4- 
+AD4- I managed to convince my self that there wasn't a problem as long as
+AD4- xs+AF8-tcp+AF8-setup+AF8-socket never called into xs+AF8-close.
+AD4- Otherwise the worst case is that one thread running xs+AF8-close could block
+AD4- while some other thread runs xs+AF8Aew-tcp,udp+AH0AXw-setup+AF8-socket.

OK. Let's go with that then. Could you please resend as a formal patch?

Cheers,
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
