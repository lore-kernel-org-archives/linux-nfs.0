From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 24 Sep 2008 13:42:30 -0400
Message-ID: <20080924174230.GJ5772@fieldses.org>
References: <48D15DF0.4000406@panasas.com> <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com> <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com> <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost> <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58158 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652AbYIXRmh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 13:42:37 -0400
In-Reply-To: <1222277168.7390.19.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2008 at 01:26:08PM -0400, Trond Myklebust wrote:
> On Wed, 2008-09-24 at 13:21 -0400, J. Bruce Fields wrote:
> > > Well the current implementation is certainly broken.  Look at what
> > > happens if I clone the rpc_clnt...
> > 
> > Hence the comment that "we assume this rpc_client is the last user of
> > the program."  I believe that assumption is correct in the case of nfsd
> > callbacks, so Benny's patch is at least not broken--just a little
> > ad-hoc.
> > 
> > So the question is whether the above solution, which addresses only this
> > particular case, is sufficient, or whether we'd like something more
> > general, like adding a reference count to the program along with a
> > free_program callback called only on the final put.
> 
> It's broken...

If by "broken" you mean, "introduces a new kernel bug", I don't see it.

The new free_rpc_program callback is set only in
fs/nfsd/nfs4callback.c:do_probe_callback().  For all other programs it
is NULL, thus there's no change of behavior.

And rpc_clone_client() is never called on the client created in
do_probe_callback().

If your argument that it's ugly to introduce a rule like that requires
you never to call rpc_clone_client on a cllient with certain properties,
then I can agree.  (In that case, does a reference count on the program
look like an acceptable solution?)

If there's some other bug, then I'd like to understand.

--b.
