From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: Union mounts, NFS, and locking
Date: Tue, 14 Jul 2009 16:19:41 -0400
Message-ID: <20090714201940.GF27582@shell>
References: <20090714174828.GE27582@shell> <200907141819.n6EIJQi1014319@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753902AbZGNUUD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 16:20:03 -0400
In-Reply-To: <200907141819.n6EIJQi1014319-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2009 at 02:19:26PM -0400, Erez Zadok wrote:
> In message <20090714174828.GE27582@shell>, Valerie Aurora writes:
> [...]
> > (Yes, this depends on the actual concrete union mount locking scheme,
> > but I'm more interested in whether it can or cannot be solved in
> > principle.)
> 
> Val,
> 
> To solve this "in principle" would require a semantic change to all
> network-based file systems (not just NFS).  You'll find yourself deep inside
> age-old distributed systems and distributed locking issues---hard problems
> (you've got plenty to worry about w/o having to redefine NFS semantics :-)

Makes sense.

> IMHO it's not worth at this stage to try and solve that problem in an
> end-to-end manner (client to server).  For a unioning layer to have to worry
> about every possible change in any of the layers below it, is no different
> than for every possible network-filesystem client to be able to guarantee
> that nothing ever changes on the server unexpectedly: they don't, so why
> should you have to solve this problem now?  Not that I don't think it's an
> important problem---I just don't see why *you* should have to solve this and
> not the network-filesystem community: whatever solution that can come up,
> can be applicable to any unioning layer.  In the mean time, do the best you
> can (e.g., ESTALE, readonly superblocks, etc.).

Okay, so my best idea for a solution is to introduce a new NFS mount
option that means the server promises that the exported file system is
read-only (using superblock read-only count scheme locally).  E.g.:

/etc/exports:
/client_root_fs   thin-client-*.local.domain(server_ro,no_root_squash)

Trond, is this super-gross or totally reasonable?  Seems like we add
new NFS mount options at the drop of a hat.

-VAL
