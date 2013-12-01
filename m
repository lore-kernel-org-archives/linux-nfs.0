Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627Ab3LAP6M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Dec 2013 10:58:12 -0500
Date: Sun, 1 Dec 2013 10:57:48 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Message-ID: <20131201105748.5db27670@tlielax.poochiereds.net>
In-Reply-To: <20131201104422.64a8c7a0@tlielax.poochiereds.net>
References: <20131201131441.790963326@bombadil.infradead.org>
	<20131201104422.64a8c7a0@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 1 Dec 2013 10:44:22 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Sun, 01 Dec 2013 05:14:41 -0800
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > This series tries to get rid of the damage created by sprinkling the
> > network namespace cat poo all over rpc_pipefs and users.
> > 
> > Instead of getting lost in a maze of notifiers and infrastructure build
> > around it a cargo cult manner we revert to a slightly nicer version of
> > the pre-namespace API.
> > 
> > To do this we just have to create an in-kernel instance of rpc_pipefs
> > that is mounted at network namespace creation so that all functions can
> > operated on it.
> > 
> > As-is this has one major downside: because the initial mount already grabs
> > a reference to the network namespace we'll create a cyclic reference and
> > will never free the network namespace.  To get around this we'd need
> > some way to only grab it once user mounts show up / disapear in the VFS.
> > 
> > Given that the namespace kraken has infected various internal filesystem
> > and will get more soon I suspect this problem is or will become generic
> > and will need a proper solution anyway.  Al, any good ideas how to deal
> > with this?  Most straight forward way would be to add a counter of
> > user vfsmount to the superblock and methods when it goes to 1 and 0,
> > but that seems a bit ugly.
> 
> I see what you mean here...hrm...
> 
> One possibility (though it may have holes that I don't see right
> offhand):
> 
> Don't call get_ns in rpc_fill_super. Do it in rpc_mount instead, and
> only take the reference if MS_KERNMOUNT isn't set?

...except that we have no mechanism to put those references on each
umount. Nevermind...

-- 
Jeff Layton <jlayton@redhat.com>
