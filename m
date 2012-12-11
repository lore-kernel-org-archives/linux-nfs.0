Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40527 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab2LKPf3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 10:35:29 -0500
Date: Tue, 11 Dec 2012 10:35:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
Message-ID: <20121211153527.GC3336@fieldses.org>
References: <20121206153204.30693.11408.stgit@localhost.localdomain>
 <20121206153447.30693.54128.stgit@localhost.localdomain>
 <20121210202842.GB17350@fieldses.org>
 <50C73C60.8060405@parallels.com>
 <50C73F58.1080005@parallels.com>
 <20121211145621.GA3336@fieldses.org>
 <50C74C14.8030807@parallels.com>
 <20121211152036.GB3336@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121211152036.GB3336@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2012 at 10:20:36AM -0500, J. Bruce Fields wrote:
> On Tue, Dec 11, 2012 at 07:07:00PM +0400, Stanislav Kinsbursky wrote:
> > I don't really understand, how  mountd's root can be wrong. I.e.
> > its' always right as I see it. NFSd kthreads have to swap/use
> > relative path/whatever to communicate with proper mountd.
> > Or I'm missing something?
> 
> Ugh, I see the problem: I thought svc_export_request was called at the
> time mountd does the read, but instead its done at the time nfsd does
> the upcall.
> 
> I suspect that's wrong, and we really want this done in the context of
> the mountd process when it does the read call.  If d_path is called
> there then we have no problem.

Right, so I'd be happier if we could modify sunrpc_cache_pipe_upcall to
skip calling cache_request and instead delay that until cache_read().  I
think that should be possible.

--b.
