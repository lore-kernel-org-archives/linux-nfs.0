Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46146 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab3J1VLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 17:11:19 -0400
Date: Mon, 28 Oct 2013 17:11:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] NFSD: Create nfs v4.2 decode ops
Message-ID: <20131028211118.GN31322@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-3-git-send-email-bjschuma@netapp.com>
 <20131028205414.GL31322@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9534E7CEF@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9534E7CEF@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 08:59:59PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > Sent: Monday, October 28, 2013 4:54 PM
> > To: Schumaker, Bryan
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: [PATCH 2/4] NFSD: Create nfs v4.2 decode ops
> > 
> > On Mon, Oct 28, 2013 at 10:57:24AM -0400, Anna Schumaker wrote:
> > > I'm doing this in a separate patch to keep from putting in a lot of
> > > extra code when I go to add operations to the server for real.
> > 
> > Makes sense.
> > 
> > But: now we're duplicating the list of 4.0 op decoders 3 times and the
> > 4.1 ops twice.  We'll never need different decoders for different
> > minorversions (worst case we can test for the minorversion in the decoder if
> > necessary).
> > 
> > I wonder if there's a better way to organize this....  Maybe something more
> > like a single array with
> > 
> > 	[OP_SETCLIENTID] = {
> > 		.op_decode = (nfsd4_dec)nfsd4_decode_access,
> > 		.op_unsupported_since_version = 1,
> > 	}
> > 	...
> > 	[OP_EXCHANGE_ID] = {
> > 		.op_decode = (nfsd4_dec)nfsd4_decode_exchange_id,
> > 		.op_first_supported_in_version = 1,
> > 	}
> > 
> > ?
> 
> Is that really necessary? Why not just have a single array and have nfsd4_decode_clientid itself check the minor version?

That'd work too.  Every operation that's been introduced more recently
than 4.0 or that's since been deprecated would need a version check at
the top of its decoder.  That'd be a dozen or so.

But the information has to go somewhere and perhaps that's more
straightforward than sticking this in data....  OK, I'd be fine with
that.

--b.
