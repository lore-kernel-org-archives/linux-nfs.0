From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 24 Sep 2008 13:26:08 -0400
Message-ID: <1222277168.7390.19.camel@localhost>
References: <48D15DF0.4000406@panasas.com>
	 <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com>
	 <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com>
	 <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost>
	 <20080924172134.GI5772@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60125 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbYIXR0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 13:26:16 -0400
In-Reply-To: <20080924172134.GI5772@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-09-24 at 13:21 -0400, J. Bruce Fields wrote:
> > Well the current implementation is certainly broken.  Look at what
> > happens if I clone the rpc_clnt...
> 
> Hence the comment that "we assume this rpc_client is the last user of
> the program."  I believe that assumption is correct in the case of nfsd
> callbacks, so Benny's patch is at least not broken--just a little
> ad-hoc.
> 
> So the question is whether the above solution, which addresses only this
> particular case, is sufficient, or whether we'd like something more
> general, like adding a reference count to the program along with a
> free_program callback called only on the final put.

It's broken...

Trond

