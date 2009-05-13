Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41815 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbZEMAox (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 20:44:53 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4D0Z4CZ001495
	for <linux-nfs@vger.kernel.org>; Tue, 12 May 2009 20:35:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4D0iscf257172
	for <linux-nfs@vger.kernel.org>; Tue, 12 May 2009 20:44:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4D0ir8I002660
	for <linux-nfs@vger.kernel.org>; Tue, 12 May 2009 20:44:54 -0400
Date: Tue, 12 May 2009 17:44:52 -0700
From: Matt Helsley <matthltc@us.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Matt Helsley <matthltc@us.ibm.com>,
        Containers <containers@lists.osdl.org>, linux-nfs@vger.kernel.org
Subject: Re: [RFC][PATCH] Improve NFS use of network and mount namespaces
Message-ID: <20090513004452.GF3912@us.ibm.com>
References: <20090512215138.GD3912@us.ibm.com> <1242172010.5407.79.camel@heimdal.trondhjem.org> <m13ab97trc.fsf@fess.ebiederm.org> <1242173604.5407.82.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1242173604.5407.82.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 12, 2009 at 08:13:24PM -0400, Trond Myklebust wrote:
> On Tue, 2009-05-12 at 17:04 -0700, Eric W. Biederman wrote:
> > Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> > 
> > > Finally, what happens if someone decides to set up a private socket
> > > namespace, using CLONE_NEWNET, without also using CLONE_NEWNS to create
> > > a private mount namespace? Would anyone have even the remotest chance in
> > > hell of figuring out what filesystem is mounted where in the ensuing
> > > chaos?
> > 
> > Good question.  Multiple NFS servers with the same ip address reachable
> > from the same machine sounds about as nasty pickle as it gets.
> > 
> > The only way I can even imagine a setup like that is someone connecting
> > to a vpn.  So they are behind more than one NAT gateway.
> > 
> > Bleh NAT sucks.
> 
> It is doable, though, and it will affect more than just NFS. Pretty much
> all networked filesystems are affected.
> 
> It begs the question: is there ever any possible justification for
> allowing CLONE_NEWNET without implying CLONE_NEWNS?

There are so many filesystem-based kernel APIs that this is a pervasive
problem IMHO -- not just with CLONE_NEWNET. However, even if we required
CLONE_NEWNET|CLONE_NEWNS network namespaces still present a problem to
network filesystems in general.

-Matt
