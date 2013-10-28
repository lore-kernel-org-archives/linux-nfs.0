Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:23642 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756885Ab3J1VAA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 17:00:00 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 2/4] NFSD: Create nfs v4.2 decode ops
Date: Mon, 28 Oct 2013 20:59:59 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9534E7CEF@SACEXCMBX04-PRD.hq.netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-3-git-send-email-bjschuma@netapp.com>
 <20131028205414.GL31322@fieldses.org>
In-Reply-To: <20131028205414.GL31322@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, October 28, 2013 4:54 PM
> To: Schumaker, Bryan
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 2/4] NFSD: Create nfs v4.2 decode ops
> 
> On Mon, Oct 28, 2013 at 10:57:24AM -0400, Anna Schumaker wrote:
> > I'm doing this in a separate patch to keep from putting in a lot of
> > extra code when I go to add operations to the server for real.
> 
> Makes sense.
> 
> But: now we're duplicating the list of 4.0 op decoders 3 times and the
> 4.1 ops twice.  We'll never need different decoders for different
> minorversions (worst case we can test for the minorversion in the decoder if
> necessary).
> 
> I wonder if there's a better way to organize this....  Maybe something more
> like a single array with
> 
> 	[OP_SETCLIENTID] = {
> 		.op_decode = (nfsd4_dec)nfsd4_decode_access,
> 		.op_unsupported_since_version = 1,
> 	}
> 	...
> 	[OP_EXCHANGE_ID] = {
> 		.op_decode = (nfsd4_dec)nfsd4_decode_exchange_id,
> 		.op_first_supported_in_version = 1,
> 	}
> 
> ?

Is that really necessary? Why not just have a single array and have nfsd4_decode_clientid itself check the minor version?

Cheers
 Trond
