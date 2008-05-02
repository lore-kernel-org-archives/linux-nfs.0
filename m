From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lock reclaims outside grace period
Date: Fri, 2 May 2008 16:04:10 -0400
Message-ID: <20080502200410.GF21918@fieldses.org>
References: <20080429215707.GF26468@fieldses.org> <1209507531.8321.11.camel@heimdal.trondhjem.org> <20080430000349.GA32692@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646AbYEBUEN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 16:04:13 -0400
In-Reply-To: <20080430000349.GA32692@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 29, 2008 at 08:03:49PM -0400, bfields wrote:
> On Tue, Apr 29, 2008 at 03:18:51PM -0700, Trond Myklebust wrote:
> > 
> > On Tue, 2008-04-29 at 17:57 -0400, J. Bruce Fields wrote:
> > > Current lockd code appears to reject regular locks done during the grace
> > > period, but not reclaims that come outside of the grace period.
> > > 
> > > (That's based on inspecting the code--I haven't run tests.)
> > > 
> > > That seems like an obvious bug.  (We're not giving the client any way to
> > > determine whether conflicting locks might have been granted.)
> > > 
> > > Can we fix it, or is there a chance that people have been depending on
> > > this behavior?  (Maybe for failing over to an already-active server??)
> > 
> > Sorry, but I really don't care if anyone has been relying on it: that is
> > a _major_ bug and needs to be fixed ASAP.
> 
> OK, good, I'll do some tests to confirm and then submit a patch.

Well, I figured the easiest way to reproduce the problem would be just
by acquiring a lock on a client, then playing tricks with the network to
cause it to miss the grace period.

But I'm not getting statd to work--or at least, I'm not seeing any statd
activity on the network.  There must be something basic wrong with my
configuration, but I haven't found it yet.

--b.

> 
> When I ran across this I checked what specs I could find (mostly
> wondering which error to return), and was surprised to find no mention
> of this case.  For example, from the Open Group XNFS spec
> (http://www.opengroup.org/onlinepubs/9629799/):
> 
> 	"If "reclaim" is true, then the server will assume this is a
> 	request to re-establish a previous lock (for example, after the
> 	server has crashed and rebooted). During the grace period the
> 	server will only accept locks with "reclaim" set to true."
> 
> But they don't state the converse.
> 
> And LCK_DENIED_GRACE_PERIOD "Indicates that the procedure failed because
> the server host has recently been rebooted and the server NLM is
> re-establishing existing locks, and is not yet ready to accept normal
> service requests."  But absent an objection I suppose I'll use
> LCK_DENIED_GRACE_PERIOD for the other case too.
> 
> Anyway, it all made me worry whether ignoring the late-reclaim case was
> actually standard behavior.  It wouldn't be the only weird thing about
> NLM.
> 
> --b.
