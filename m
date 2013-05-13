Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38538 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab3EMPjZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 May 2013 11:39:25 -0400
Date: Mon, 13 May 2013 11:39:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        James Morris <jmorris@namei.org>
Subject: Re: 3.11 patches
Message-ID: <20130513153922.GC1931@fieldses.org>
References: <20130513152312.GB1931@fieldses.org>
 <1368458889.3563.7.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368458889.3563.7.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 13, 2013 at 03:28:09PM +0000, Myklebust, Trond wrote:
> On Mon, 2013-05-13 at 11:23 -0400, J. Bruce Fields wrote:
> > I've added a labeled-nfs-common branch at
> > 
> > 	git://linux-nfs.org/~bfields/linux.git labeled-nfs-common
> > 
> > with 3.10-rc1 + the one labeled NFS patch shared by client and server
> > (with just some protocol constants).
> > 
> > So we can all work on top of that if we want.
> 
> OK. I've pushed out a 'labeled-nfs' branch for the client side that is
> based upon the above branch.
> 
> Has James added the security patches to a public branch that we can pull
> yet?

I assumed his ACK meant he was comfortable with us merging them.

None of them are needed on the server side as far as I can tell, so
that'd mean they'd go through your tree.

James, is that OK with you?

--b.
