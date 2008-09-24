From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 24 Sep 2008 14:42:25 -0400
Message-ID: <1222281745.7390.34.camel@localhost>
References: <48D15DF0.4000406@panasas.com>
	 <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com>
	 <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com>
	 <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost>
	 <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost>
	 <20080924174230.GJ5772@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60907 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbYIXSme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 14:42:34 -0400
In-Reply-To: <20080924174230.GJ5772@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-09-24 at 13:42 -0400, J. Bruce Fields wrote:

> If by "broken" you mean, "introduces a new kernel bug", I don't see it.

I mean it introduces utterly unnecessary complications that may return
to bite us in the arse at a future time.
Remember how we once said that it would never make sense for child
clones to call the portmapper, and so we added the BUG_ON() in
rpcb_getport_async; well guess what, we currently have a bug to fix...

One pretty obvious fix is to simply move the release method so that it
doesn't occur when you release a child. The disadvantage is that a child
may then not change its program to one that requires a release method
(do we need that?).

Another fix would be to add a refcount to the rpc_program structure...

Trond

