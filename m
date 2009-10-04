From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [2.6.31] NFS4ERR_GRACE unhandled...
Date: Sun, 04 Oct 2009 18:10:52 -0400
Message-ID: <1254694252.30515.63.camel@heimdal.trondhjem.org>
References: <6278d2220909261114g2e1529dfn4961d450460b00dc@mail.gmail.com>
	 <1254161800.3308.1.camel@heimdal.trondhjem.org>
	 <6278d2220910030859s1fb8d200n7d032e2c1b235ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27898 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758093AbZJDWLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Oct 2009 18:11:45 -0400
In-Reply-To: <6278d2220910030859s1fb8d200n7d032e2c1b235ce-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-10-03 at 16:59 +0100, Daniel J Blueman wrote:
> Hi Trond,
> 
> On Mon, Sep 28, 2009 at 7:16 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Sat, 2009-09-26 at 19:14 +0100, Daniel J Blueman wrote:
> >> Hi Trond,
> >>
> >> After rebooting my 2.6.31 NFS4 server, I see a list of NFS kernel
> >> errors [1] on the 2.6.31 client corresponding to NFS4ERR_GRACE, so
> >> lock or file state recovery failed. Is this expected noting that I
> >> have an internal firewall allowing incoming TCP port 2049 on the
> >> server, and no firewall on the client, however I can't see how it can
> >> thus be callback related?
> >
> > No. It looks as if your server rebooted while the client was recovering
> > an expired lease.
> >
> > The following patch should prevent future occurrences of this bug...
> >
> > Cheers
> >  Trond
> > ------------------------------------------------------------------
> > NFSv4: Handle NFS4ERR_GRACE when recovering an expired lease.
> >
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> >
> > If our lease expires, and the server subsequently reboot, we need to be
> > able to handle the case where the server refuses to let us recover state,
> > because it is in the grace period.
> 
> On the client, I didn't see the error messages with this patch,
> however I did see firefox (via sqlite) continue to hang [1] (after
> other processes continued), and an unusual level of activity with
> rpciod/0 and rpciod/1 kernel threads. Other NFS-related kernel thread
> state is given.

What are your mount options?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
