From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 25 Sep 2008 16:38:55 -0400
Message-ID: <20080925203855.GA14349@fieldses.org>
References: <48D2AAF7.6060808@panasas.com> <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost> <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost> <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost> <20080924184934.GK5772@fieldses.org> <48DBE6D9.3010603@panasas.com> <1222373338.13388.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60731 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbYIYUjA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 16:39:00 -0400
In-Reply-To: <1222373338.13388.19.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 04:08:58PM -0400, Trond Myklebust wrote:
> On Thu, 2008-09-25 at 22:30 +0300, Benny Halevy wrote:
> > One more thing that seems to need fixing is rpc_bind_new_program
> > which now uses the passed-in program->cl_stats but doesn't point
> > to the passed-in program, but rather it only extracts its
> > name, number, and stats.
> > Since program->stats may possibly go away with the program
> > in the refcounted world I think we should get a reference on the
> > program here too.
> > 
> > That observed, it may also be a good idea to get rid of clnt->cl_stats
> > altogether and use clnt->program->stats instead to prevent any
> > discrepancy.
> 
> No. cl_stats are _per_client_ stats. program->stats are per protocol.
> You can't just substitute one for the other.

A "git grep cl_stats" only finds me two places where it's assigned to,
both of the form

	clnt->cl_stats    = program->stats;

So it looks per-program; am I missing something?

--b.
