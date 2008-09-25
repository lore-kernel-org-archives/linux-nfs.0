From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 25 Sep 2008 16:08:58 -0400
Message-ID: <1222373338.13388.19.camel@localhost>
References: <20080917231018.GA5723@fieldses.org>
	 <48D193EE.2020805@panasas.com> <48D19C74.8000303@panasas.com>
	 <48D2AAF7.6060808@panasas.com> <20080924163528.GB5772@fieldses.org>
	 <1222275582.7390.8.camel@localhost> <20080924172134.GI5772@fieldses.org>
	 <1222277168.7390.19.camel@localhost> <20080924174230.GJ5772@fieldses.org>
	 <1222281745.7390.34.camel@localhost> <20080924184934.GK5772@fieldses.org>
	 <48DBE6D9.3010603@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:33239 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753473AbYIYUJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 16:09:19 -0400
In-Reply-To: <48DBE6D9.3010603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-09-25 at 22:30 +0300, Benny Halevy wrote:
> One more thing that seems to need fixing is rpc_bind_new_program
> which now uses the passed-in program->cl_stats but doesn't point
> to the passed-in program, but rather it only extracts its
> name, number, and stats.
> Since program->stats may possibly go away with the program
> in the refcounted world I think we should get a reference on the
> program here too.
> 
> That observed, it may also be a good idea to get rid of clnt->cl_stats
> altogether and use clnt->program->stats instead to prevent any
> discrepancy.

No. cl_stats are _per_client_ stats. program->stats are per protocol.
You can't just substitute one for the other.

Trond

