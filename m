Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:54201 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779Ab3ENB7f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 May 2013 21:59:35 -0400
Date: Tue, 14 May 2013 12:05:01 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.11 patches
In-Reply-To: <20130513153922.GC1931@fieldses.org>
Message-ID: <alpine.LRH.2.02.1305141204520.1521@tundra.namei.org>
References: <20130513152312.GB1931@fieldses.org> <1368458889.3563.7.camel@leira.trondhjem.org> <20130513153922.GC1931@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 May 2013, J. Bruce Fields wrote:

> On Mon, May 13, 2013 at 03:28:09PM +0000, Myklebust, Trond wrote:
> > On Mon, 2013-05-13 at 11:23 -0400, J. Bruce Fields wrote:
> > > I've added a labeled-nfs-common branch at
> > > 
> > > 	git://linux-nfs.org/~bfields/linux.git labeled-nfs-common
> > > 
> > > with 3.10-rc1 + the one labeled NFS patch shared by client and server
> > > (with just some protocol constants).
> > > 
> > > So we can all work on top of that if we want.
> > 
> > OK. I've pushed out a 'labeled-nfs' branch for the client side that is
> > based upon the above branch.
> > 
> > Has James added the security patches to a public branch that we can pull
> > yet?
> 
> I assumed his ACK meant he was comfortable with us merging them.
> 
> None of them are needed on the server side as far as I can tell, so
> that'd mean they'd go through your tree.
> 
> James, is that OK with you?

Yep.

-- 
James Morris
<jmorris@namei.org>
