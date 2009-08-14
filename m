From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in
 encode_create_session and encode_sequence
Date: Fri, 14 Aug 2009 15:48:54 -0400
Message-ID: <1250279334.5476.60.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>
	 <1250259553-13672-1-git-send-email-bhalevy@panasas.com>
	 <9734995E-20F8-4E53-83CD-BA95145D15ED@oracle.com>
	 <1250269055.5476.11.camel@heimdal.trondhjem.org>
	 <10346A84-B1F3-4161-B518-0F5D68D2DC9B@oracle.com>
	 <1250278083.5476.51.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59162 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756556AbZHNTtD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2009 15:49:03 -0400
In-Reply-To: <1250278083.5476.51.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-14 at 15:28 -0400, Trond Myklebust wrote:
> No, it won't. The encode_*/decode_* routines reflect unique operations.
> There is little or no overlap between what they encode/decode, so there
> isn't much room for sharing macros between them.
> Instead, we attempt to describe each encode_*/decode_* routine using its
> own *maxsz macro.
> 
> The exceptions to the 'no sharing' rule are sub-objects like stateids,
> verifiers, and session ids. There we _do_ use macros both in the
> reserve_space() calls, and in the ensuing opaque_encode/decode call.
> However as you saw in the patch series, a better alternative is to give
> them their own unique encode_stateid/decode_stateid routine that can be
> checked once and for all against
> encode_stateid_maxsz/decode_stateid_maxsz.

By the way, I wouldn't be opposed to moving the definitions of the
*maxsz macros down, so that each one is next to the function that it
describes. That would facilitate the process of checking at a glance
whether or not the buffer memory allocation and XDR code expectations
match one another.

It's not too urgent a project, though.

  Trond

