Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33916 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbaFBQ5R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 12:57:17 -0400
Date: Mon, 2 Jun 2014 12:57:16 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Devesh Sharma'" <Devesh.Sharma@Emulex.Com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, tom@opengridcomputing.com
Subject: Re: [PATCH V3] svcrdma: refactor marshalling logic
Message-ID: <20140602165716.GB20031@fieldses.org>
References: <20140529165532.16349.95248.stgit@build.ogc.int>
 <EE7902D3F51F404C82415C4803930ACD3FE01265@CMEXMB1.ad.emulex.com>
 <000001cf7c07$72e613d0$58b23b70$@opengridcomputing.com>
 <EE7902D3F51F404C82415C4803930ACD3FE01355@CMEXMB1.ad.emulex.com>
 <004101cf7e82$68b58ad0$3a20a070$@opengridcomputing.com>
 <20140602165151.GA20031@fieldses.org>
 <004901cf7e83$15107790$3f3166b0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <004901cf7e83$15107790$3f3166b0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 02, 2014 at 11:52:47AM -0500, Steve Wise wrote:
> > > You're correct.  And this bug appears to be in the current upstream code as well.  If
> an
> > > IB_WR_LOCAL_INV wr is used, it must include IB_SEND_FENCE to fence it until the prior
> > read
> > > completes.
> > >
> > > Good catch!  I'll post V4 soon.
> > 
> > Any chance that can be handled as a separate patch rather than folded
> > in?
> > 
> > (Disclaimer: I've been following the discussion only very
> > superficially.)
> > 
> 
> Sure.  I'll post the patch soon.

Thanks, and, again, I'm not terribly happy about the monster
patch--anything you can split off it is great, even if that thing's
small.  As long as all the intermediate stages still build and run.

(And any bugs you've identified in upstream code are good candidates for
separate patches, hopefully preceding the rewrite.  That also allows us
to apply those fixes to stable kernels if appropriate.)

--b.
