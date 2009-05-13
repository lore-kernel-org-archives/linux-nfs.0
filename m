Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54672 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752273AbZEMANd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 20:13:33 -0400
Subject: Re: [RFC][PATCH] Improve NFS use of network and mount namespaces
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Matt Helsley <matthltc@us.ibm.com>, Containers <containers@lists.osdl.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <m13ab97trc.fsf@fess.ebiederm.org>
References: <20090512215138.GD3912@us.ibm.com>
	 <1242172010.5407.79.camel@heimdal.trondhjem.org>
	 <m13ab97trc.fsf@fess.ebiederm.org>
Content-Type: text/plain
Date: Tue, 12 May 2009 20:13:24 -0400
Message-Id: <1242173604.5407.82.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-05-12 at 17:04 -0700, Eric W. Biederman wrote:
> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> > Finally, what happens if someone decides to set up a private socket
> > namespace, using CLONE_NEWNET, without also using CLONE_NEWNS to create
> > a private mount namespace? Would anyone have even the remotest chance in
> > hell of figuring out what filesystem is mounted where in the ensuing
> > chaos?
> 
> Good question.  Multiple NFS servers with the same ip address reachable
> from the same machine sounds about as nasty pickle as it gets.
> 
> The only way I can even imagine a setup like that is someone connecting
> to a vpn.  So they are behind more than one NAT gateway.
> 
> Bleh NAT sucks.

It is doable, though, and it will affect more than just NFS. Pretty much
all networked filesystems are affected.

It begs the question: is there ever any possible justification for
allowing CLONE_NEWNET without implying CLONE_NEWNS?

Trond

