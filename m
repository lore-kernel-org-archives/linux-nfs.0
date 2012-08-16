Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43512 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932636Ab2HPUmL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 16:42:11 -0400
Date: Thu, 16 Aug 2012 16:42:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: v3.5 nfsd4 regression; utime sometimes takes 40+ seconds to
 return
Message-ID: <20120816204208.GE4385@fieldses.org>
References: <20120815061115.GC32347@cucamonga.audible.transient.net>
 <20120815135854.GI32347@cucamonga.audible.transient.net>
 <20120815150251.GB16057@fieldses.org>
 <20120816201838.GA4282@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120816201838.GA4282@cucamonga.audible.transient.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 16, 2012 at 08:18:38PM +0000, Jamie Heilman wrote:
> J. Bruce Fields wrote:
> > On Wed, Aug 15, 2012 at 01:58:54PM +0000, Jamie Heilman wrote:
> > > Jamie Heilman wrote:
> > > > I'll try to get full rcpdebug traces on client and server as the delay
> > > > is occuring in the hopes that helps pin things down, and post them
> > > > separately.
> > > 
> > > OK, here are the logs from client and server, where a run of my test program
> > > under strace -T resulted in:
> > > 
> > > utime("utime-test.c", [2012/08/15-13:35:20, 2012/08/15-13:22:04]) = 0 <0.150815>
> > > open("utime-test.c", O_RDONLY)          = 3 <0.242635>
> > > close(3)                                = 0 <0.147768>
> > > stat("utime-test.c", {st_mode=S_IFREG|0644, st_size=696, ...}) = 0 <0.002772>
> > > utime("utime-test.c", [2012/08/15-13:35:20, 2012/08/15-13:22:04]) = 0 <71.878058>
> > > 
> > > The client is a 64-bit v3.4.8 kernel, the server is 32-bit, v3.5.1 +
> > > the two sunprc patches that will be in v3.5.2.
> > > 
> > > (The client's system clock is a touch faster than the server's, but
> > > these logs start at the same instant.)
> > 
> > Thanks for all the details.
> > 
> > What's probably happening is that the client is returning a delegation
> > with the open.  The setattr then breaks that delegation; you can see it
> > getting 10008 (NFS4ERR_DELAY) replies while the server waits for the
> > delegation to be returned.  But for some reason the callback to break
> > the delegation isn't working.  ("NFSD: warning: no callback path to
> > client 192.168.2.42/192.168.2.4 tcp UNIX 0: error -110" (110 is
> > ETIMEDOUT).)  So instead you wait for the delegation to time out and get
> > forcibly revoked.
> > 
> > The reproducer might be more reliable if you did two opens.
> 
> I made the change... not entirely sure it helped, but I think I've
> bisected this reliably anyway.  It came down to:

Hm, weird.  In the good case the cb_recall's done with auth_unix, in the
bad case with auth_null.  OK, that should be enough to go on....

Thanks for digging into this!

--b.

> 
> d5497fc693a446ce9100fcf4117c3f795ddfd0d2 is the first bad commit
> commit d5497fc693a446ce9100fcf4117c3f795ddfd0d2
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon May 14 22:06:49 2012 -0400
> 
>     nfsd4: move rq_flavor into svc_cred
>     
>     Move the rq_flavor into struct svc_cred, and use it in setclientid and
>     exchange_id comparisons as well.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> :040000 040000 165568aae0fc47067863ea8ca911494033cbf2ce 54244f0084f58df4844b09d56e8e6bad0e19d913 M      fs
> :040000 040000 bae5a74a85bda2aa2b155b0bdca1ea0028502164 207751ce30c8f49c68fb0a85d0772cb0fa426ae1 M      include
> :040000 040000 ef940cf0c558fe65a21a710e6c95b2cefb2996fd 459ac143acf5cb2b3b7f59df29c417cedbb23c4b M      net
> 
> FWIW reverting this commit does seem to fix the problem.
> 
> > It'd be worth looking at the traffic in wireshark.  You should see
> > setattr, open, close, setattr, a DELAY reply to the setattr, a
> > CB_RECALL, and then a DELEGRETURN that gets a succesful reply.  But for
> > some reason the DELEGRETURN isn't getting through in your case, I'm not
> > sure why.  I can't reproduce that.  You'll need to start wireshark
> > before you mount to make sure it knows how to parse the callbacks.
> 
> Captures from the server showing the delay (running 3.5.2) and the
> previous behavior (running 3.4.9) are attached.
> 
> -- 
> Jamie Heilman                     http://audible.transient.net/~jamie/



