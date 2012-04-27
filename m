Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760227Ab2D0Pll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 11:41:41 -0400
Date: Fri, 27 Apr 2012 11:41:33 -0400
From: Josh Boyer <jwboyer@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Add modalias for "nfs4"
Message-ID: <20120427154123.GE13189@zod.bos.redhat.com>
References: <20120427131031.GA13189@zod.bos.redhat.com>
 <20120427141918.GA15506@umich.edu>
 <20120427144840.GB13189@zod.bos.redhat.com>
 <1335538228.3910.1.camel@lade.trondhjem.org>
 <20120427145352.GC13189@zod.bos.redhat.com>
 <1335538927.3910.3.camel@lade.trondhjem.org>
 <20120427151406.GD13189@zod.bos.redhat.com>
 <1335540074.3910.9.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335540074.3910.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 03:21:15PM +0000, Myklebust, Trond wrote:
> > > > OK.  So either this patch needs to go in, or something needs to add:
> > > > 
> > > > alias nfs4 nfs
> > > > 
> > > > to a conf file so modprobe picks it up.  I figured the kernel could add
> > > > the alias itself.  Is there a reason not to?
> > > 
> > > Yes. This is a legacy feature that we want to encourage people to move
> > > their systems off...
> > 
> > So essentially what needs to happen is:
> > 
> > - Recent distros still ship the modalias in a conf file
> > - Upstream nfs-utils starts translating 'mount -t nfs4' into 'mount -t
> >   nfs -overs=4' in /sbin/mount.nfs4
> > - Upstream releases that
> > - Distros drop the alias.
> > 
> > Right?
> 
> No. Really all we need to do is add a printf() to /sbin/mount.nfs4 to
> the effect that this is a legacy feature and that '-t nfs -overs=4' is
> the recommended mount option. Perhaps the distros can also have their
> distro upgrade utilities edit /etc/fstab to upgrade those automatically.
> 
> Then the distros can drop the alias whenever they think it is
> appropriate.

My limited experience shows that people won't change their habits until
those habits simply no longer work.  Adding a printf is probably a fine
thing to do, but I'm not sure it will have much impact on how people go
about mounting NFSv4 filesystems.  That leads me to believe that the
alias will be carried along for quite a while.

Anyway, the immediate problem can be solved by just keeping the alias in
a conf file.  If that's what is recommended for now, OK.

josh
