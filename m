From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Wed, 17 Mar 2010 15:35:10 -0400
Message-ID: <1268854510.8335.19.camel@localhost.localdomain>
References: <1264796353.3644.4.camel@localhost>
	 <20100129205022.GA14449@infradead.org> <1264798623.3644.18.camel@localhost>
	 <1264799906.3644.21.camel@localhost> <20100129212706.GA28361@infradead.org>
	 <1264801151.3644.27.camel@localhost> <20100129235852.GC30852@fieldses.org>
	 <20100317150813.43815b5a@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55345 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633Ab0CQTgL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 15:36:11 -0400
In-Reply-To: <20100317150813.43815b5a-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-03-17 at 15:08 -0400, Jeff Layton wrote: 
> Is there any reason that we need to revoke the delegation on a commit?
> 
> The only real effect is that writes would be flushed to stable storage.
> The VM on the server could just decide the flush the data to stable
> storage whenever it feels like it without revoking the lease. I don't
> see why we'd need to revoke the lease just because a client asked for
> the flush.
> 
> Bruce has already chimed in on it, but a deadlock of sorts has popped
> up relating to this:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=551028#c10
> 
> ...and it seems like not recalling the delegation on a COMMIT might
> help resolve it.

I agree. A commit doesn't change the inode in any way, so it shouldn't
require you to revoke the delegation.

Furthermore, I think that the write access check there is incorrect too.
The posix definition of fsync() doesn't specify that the file descriptor
has be writeable, and since COMMIT semantics are supposed to be modelled
on fsync...

Cheers
   Trond
