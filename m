Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44470 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932761AbaDIN40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2014 09:56:26 -0400
Date: Wed, 9 Apr 2014 09:56:25 -0400
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: commit 1bc49d83c37c (nfsd4: fix nfs4err_resource in 4.1 case)
Message-ID: <20140409135625.GA22938@fieldses.org>
References: <ED8FB66B-E2A5-4BD5-95DE-160C9717D9AB@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <ED8FB66B-E2A5-4BD5-95DE-160C9717D9AB@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 09, 2014 at 09:41:28AM -0400, Trond Myklebust wrote:
> According to RFC5661, NFS4ERR_REP_TOO_BIG/NFS4ERR_REP_TOO_BIG_TO_CACHE
> are only appropriate if "The reply to a Compound would exceed the
> channel's negotiated maximum response size.”.  Given that the callers
> of nfsd4_encode_fattr appear to all pass in ‘buffer’ and ‘buflen’
> arguments that are limited to single page, doesn’t this mean that you
> can end up returning nfs4err_resource in cases where
> nfserr_rep_too_big/nfserr_rep_too_big_to_cache are simply not
> appropriate?

Yes, you're right.  This will be fixed by later patches which remove
those arbitrary single-page limits, but for now it's a bug.

This was probably a bad way to sequence those patches.

That said, all that patch is doing in those cases is replacing one
useless error by another, so in practice I don't think reverting the
patch would help anyone--so I'm inclined to leave this alone and wait
for the real bug to be fixed (which is that we're imposing limits other
than the session limits).

Is this causing some problem right now?

--b.

> Either way, the NFS client will handle this badly. There is no
> recovery for NFS4ERR_RESOURCE. and we do not ever expect to hit
> NFSERR_REP_TOO_BIG/TOO_BIG_TO_CACHE. The latter two can presumably
> only be recovered by renegotiating the session and then retrying the
> request, which won’t work here...


