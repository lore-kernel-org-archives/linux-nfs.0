From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: Union mounts, NFS, and locking
Date: Tue, 14 Jul 2009 14:19:26 -0400
Message-ID: <200907141819.n6EIJQi1014319@agora.fsl.cs.sunysb.edu>
References: <20090714174828.GE27582@shell>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Valerie Aurora <vaurora@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:55102 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbZGNSTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2009 14:19:54 -0400
In-reply-to: Your message of "Tue, 14 Jul 2009 13:48:28 EDT."
             <20090714174828.GE27582@shell>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20090714174828.GE27582@shell>, Valerie Aurora writes:
[...]
> (Yes, this depends on the actual concrete union mount locking scheme,
> but I'm more interested in whether it can or cannot be solved in
> principle.)

Val,

To solve this "in principle" would require a semantic change to all
network-based file systems (not just NFS).  You'll find yourself deep inside
age-old distributed systems and distributed locking issues---hard problems
(you've got plenty to worry about w/o having to redefine NFS semantics :-)

IMHO it's not worth at this stage to try and solve that problem in an
end-to-end manner (client to server).  For a unioning layer to have to worry
about every possible change in any of the layers below it, is no different
than for every possible network-filesystem client to be able to guarantee
that nothing ever changes on the server unexpectedly: they don't, so why
should you have to solve this problem now?  Not that I don't think it's an
important problem---I just don't see why *you* should have to solve this and
not the network-filesystem community: whatever solution that can come up,
can be applicable to any unioning layer.  In the mean time, do the best you
can (e.g., ESTALE, readonly superblocks, etc.).

For example, I cannot see how this can be solved cleanly and *portably* for
established protocols such as nfsv2/3.  For v4, it might be possible to
enforce it with new callbacks which can propagate from the v4 client all the
way up to the VFS (and thus Union Mounts).  If you're going to try and
tackle the cache-coherency beast, I strongly suggest restricting the problem
to something as "simple" and manageable as a new NFSv4 CB.

Cheers,
Erez.
