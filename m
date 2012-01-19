Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49368 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab2ASWkF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 17:40:05 -0500
Date: Thu, 19 Jan 2012 17:40:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Dr James Bruce Fields <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        xemul@parallels.com, neilb@suse.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jbottomley@parallels.com,
        davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH 0/5] SUNRPC: make caches network namespace aware
Message-ID: <20120119224002.GB5177@fieldses.org>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
 <1326986392.6114.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326986392.6114.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 19, 2012 at 10:19:52AM -0500, Trond Myklebust wrote:
> On Thu, 2012-01-19 at 18:48 +0400, Stanislav Kinsbursky wrote: 
> > One more step towards to "NFS in container".
> > With this patch set caches are allocated per network namespace.
> > 
> > The following series consists of:
> > 
> > ---
> > 
> > Stanislav Kinsbursky (5):
> >       SUNRPC: cache creation and destruction routines introduced
> >       SUNRPC: create unix gid cache per network namespace
> >       SUNRPC: create GSS auth cache per network namespace
> >       SUNRPC: ip map cache per network namespace cleanup
> >       SUNRPC: generic cache register routines removed
> 
> The patches look good, and I've applied them for now in my 'devel'
> branch so we can test them, but I'd like to get an Ack/Nack from Bruce
> before committing to merging them.

They look good to me.  I'd like to hear how they've been tested--that
done, they'll have my ack.

--b.
