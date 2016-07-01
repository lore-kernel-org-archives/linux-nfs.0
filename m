Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932167AbcGAUHo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 16:07:44 -0400
Date: Fri, 1 Jul 2016 16:07:42 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Marc Eshel <eshel@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: grace period
Message-ID: <20160701200742.GA24269@fieldses.org>
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
 <20160701160857.GB20327@fieldses.org>
 <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 01, 2016 at 10:31:55AM -0700, Marc Eshel wrote:
> It used to be that sending KILL signal to lockd would free locks and start 
> Grace period, and when setting nfsd threads to zero, nfsd_last_thread() 
> calls nfsd_shutdown that called lockd_down that I believe was causing both 
> freeing of locks and starting grace period or maybe it was setting it back 
> to a value > 0 that started the grace period.

OK, apologies, I didn't know (or forgot) that.

> Any way starting with the kernels that are in RHEL7.1 and up echo 0 > 
> /proc/fs/nfsd/threads doesn't do it anymore, I assume going to common 
> grace period for NLM and NFSv4 changed things.
> The question is how to do IP fail-over, so when a node fails and the IP is 
> moving to another node, we need to go into grace period on all the nodes 
> in the cluster so the locks of the failed node are not given to anyone 
> other than the client that is reclaiming his locks. Restarting NFS server 
> is to distractive.

What's the difference?  Just that clients don't have to reestablish tcp
connections?

--b.

> For NFSv3 KILL signal to lockd still works but for 
> NFSv4 have no way to do it for v4.
> Marc. 
> 
> 
> 
> From:   Bruce Fields <bfields@fieldses.org>
> To:     Marc Eshel/Almaden/IBM@IBMUS
> Cc:     linux-nfs@vger.kernel.org
> Date:   07/01/2016 09:09 AM
> Subject:        Re: grace period
> 
> 
> 
> On Thu, Jun 30, 2016 at 02:46:19PM -0700, Marc Eshel wrote:
> > I see that setting the number of nfsd threads to 0 (echo 0 > 
> > /proc/fs/nfsd/threads) is not releasing the locks and putting the server 
> 
> > in grace mode.
> 
> Writing 0 to /proc/fs/nfsd/threads shuts down knfsd.  So it should
> certainly drop locks.  If that's not happening, there's a bug, but we'd
> need to know more details (version numbers, etc.) to help.
> 
> That alone has never been enough to start a grace period--you'd have to
> start knfsd again to do that.
> 
> > What is the best way to go into grace period, in new version of the
> > kernel, without restarting the nfs server?
> 
> Restarting the nfs server is the only way.  That's true on older kernels
> true, as far as I know.  (OK, you can apparently make lockd do something
> like this with a signal, I don't know if that's used much, and I doubt
> it works outside an NFSv3-only environment.)
> 
> So if you want locks dropped and a new grace period, then you should run
> "systemctl restart nfs-server", or your distro's equivalent.
> 
> But you're probably doing something more complicated than that.  I'm not
> sure I understand the question....
> 
> --b.
> 
> 
> 
> 
