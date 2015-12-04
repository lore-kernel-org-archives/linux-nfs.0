Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:38172 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755551AbbLDIiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2015 03:38:05 -0500
Date: Fri, 4 Dec 2015 09:38:03 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@poochiereds.net>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151204083803.GA2440@lst.de>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com> <565A7A14.4010902@gmail.com> <20151129084614.42fb1272@tlielax.poochiereds.net> <565BBB03.7020206@gmail.com> <20151130213420.GA31564@fieldses.org> <20151130193313.5bb10791@synchrony.poochiereds.net> <20151201115600.GA1557@lst.de> <20151201174800.407e2c40@synchrony.poochiereds.net> <20151202072504.GA15839@lst.de> <20151203220850.GC19518@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151203220850.GC19518@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2015 at 05:08:50PM -0500, J. Bruce Fields wrote:
> OK, so if I understand right, the current code is letting the rpc state
> machine drive the whole thing, and your proposal is that the rpc task
> lasts until the client either responds NFS4ERR_NOMATCHING_LAYOUT or we
> just run out of time.  (NOMATCHING_LAYOUT being the one response that
> isn't either "try again" or "OK I'll get to it soon").

Yes (except fatal errors would end the rpc state machine).

> I understand why that would work, and that handling anything other than
> the NOMATCHING_LAYOUT case is a lower priority for now, but this
> approach worries me.
> 
> Is there a reason we can't do as in the delegation case, and track the
> revocation timeout separately from the callback rpc?

There is no reason not to do it, except for the significant effort
to implement it a well as a synthetic test case to actually reproduce
the behavior we want to handle.
