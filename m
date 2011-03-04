From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Security] [PATCH] nfs4: Ensure that ACL pages sent over NFS
 were not allocated from the slab
Date: Fri, 4 Mar 2011 16:04:14 -0500
Message-ID: <20110304210414.GD21260@fieldses.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
 <20110304171320.GA19496@fieldses.org>
 <20110304184505.GB10083@hmsreliant.think-freely.org>
 <20110304193325.GB21260@fieldses.org>
 <AANLkTimpX6JPWyPgB6vcZ8TuQ5gj9aPcJ9OCK186n5Nk@mail.gmail.com>
 <20110304200703.GC21260@fieldses.org>
 <20110304153059.79374df7@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	security@kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44995 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932452Ab1CDVE3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2011 16:04:29 -0500
In-Reply-To: <20110304153059.79374df7-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 04, 2011 at 03:30:59PM -0500, Jeff Layton wrote:
> On Fri, 4 Mar 2011 15:07:03 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > In this case, we're not kfree()'ing until we've gotten an rpc reply
> > back.  But in theory perhaps there could be cases where the server's
> > gotten the data and we've seen the reply but the tcp layer still thinks
> > it needs to retransmit something?  I don't think we'd care if the data
> > was still correct in that case, but it could be an information leak if
> > nothing else.
> 
> There's also timeouts + soft mounts to consider. We may send the data
> on the socket, which gets buffered up and then the caller goes to sleep
> waiting for a reply. If that never comes (server crashed or something),
> then we can return an error back up to the VFS layer if it's a soft
> mount. Meanwhile, the kernel is still trying to send the data on the
> socket...

Good point, I forgot about that.

Thanks to everyone for setting me straight!

--b.
