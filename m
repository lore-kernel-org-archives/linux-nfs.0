Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24300 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933726Ab1JaSbZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 14:31:25 -0400
Subject: Re: [nfsv4] [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: linux-nfs@vger.kernel.org, nfsv4 list <nfsv4@ietf.org>,
        Benny Halevy <bhalevy@tonian.com>
Date: Mon, 31 Oct 2011 14:31:24 -0400
In-Reply-To: <553963112.119.1320085390187.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <553963112.119.1320085390187.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320085884.4714.53.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 14:23 -0400, Matt W. Benjamin wrote: 
> Hi,
> 
> Such a server implementation will certainly not be long in coming.

Good. However until then, we have nothing to test any performance claims
against.

Trond

> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Mon, 2011-10-31 at 19:57 +0200, Benny Halevy wrote: 
> 
> > > 
> > > Waiting for revocation may work well with some servers but would be
> > disastrous in
> > > terms of performance and responsiveness with others.
> > 
> > I don't necessarily disagree with what you are saying, but I have yet
> > to
> > see a single server side implementation of CB_RECALL_ANY, let alone
> > any
> > numbers that indicate performance or responsiveness problems
> > resulting
> > from our existing client-side implementation.
> > 
> > I therefore find it hard to understand why optimising this particular
> > code is such a high priority, or why a patch that is adding per-file
> > layoutreturns to initiate_bulk_draining() is going to help anything
> > at
> > all.
> > 
> >    Trond
> > 
> 
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

