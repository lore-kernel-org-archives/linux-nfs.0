Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760170Ab2D0Ox7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 10:53:59 -0400
Date: Fri, 27 Apr 2012 10:53:53 -0400
From: Josh Boyer <jwboyer@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Add modalias for "nfs4"
Message-ID: <20120427145352.GC13189@zod.bos.redhat.com>
References: <20120427131031.GA13189@zod.bos.redhat.com>
 <20120427141918.GA15506@umich.edu>
 <20120427144840.GB13189@zod.bos.redhat.com>
 <1335538228.3910.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335538228.3910.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 02:50:28PM +0000, Myklebust, Trond wrote:
> On Fri, 2012-04-27 at 10:48 -0400, Josh Boyer wrote:
> > On Fri, Apr 27, 2012 at 10:19:18AM -0400, Jim Rees wrote:
> > > Josh Boyer wrote:
> > > 
> > >   When NFSv4 is configured, the support goes into the nfs.ko module.
> > >   However, nfs-utils seems to pass "nfs4" as the fileststem type for
> > >   NFSv4 mounts.
> > > 
> > > Weren't we going to change that to nfs and use nfsvers to select nfs4?
> > 
> > I have, approximately, no idea.  At least the version of nfs-utils found
> > in Fedora 17 and rawhide, it's still using "nfs4".   I believe that is
> > nfs-utils-1.2.6-rc6 based.
> 
> nfs4 is still _supported_ in Fedora 17, rawhide and upstream as a legacy
> feature, but the recommended practice should be to mount -t nfs -overs=4
> (or -overs=4.1).

OK.  So either this patch needs to go in, or something needs to add:

alias nfs4 nfs

to a conf file so modprobe picks it up.  I figured the kernel could add
the alias itself.  Is there a reason not to?

josh
