Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52847 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755555Ab1CQXQR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 19:16:17 -0400
Date: Fri, 18 Mar 2011 10:16:08 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Bug in xdr_copy_to_scratch???
Message-ID: <20110318101608.34bb1117@notabene.brown>
In-Reply-To: <1300384865.28305.27.camel@lade.trondhjem.org>
References: <20110316213642.360be61d@notabene.brown>
	<1300282974.16266.33.camel@lade.trondhjem.org>
	<20110317093838.0f15eb98@notabene.brown>
	<1300384865.28305.27.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Mar 2011 14:01:05 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2011-03-17 at 09:38 +1100, NeilBrown wrote:
> > We should probably submit a fix to 2.6.37-stable though.  For that it
> > is possibly simplest to tell xdr_decode_inline to round nbytes up to
> > a multiple of 4 - would you agree?
> 
> How about the following fix for 2.6.37 stable?

That is good for NFSv3, but NFSv2 has the same problem.  Code fragment is
	p = xdr_inline_decode(xdr, entry->len + 4);
	if (unlikely(!p))
		goto out_overflow;
	entry->name	  = (const char *) p;
	p		 += XDR_QUADLEN(entry->len);
	entry->prev_cookie	  = entry->cookie;
	entry->cookie	  = ntohl(*p++);

so again we have the cookie after the name and they are decoded together.

This is what I have committed to openSUSE 11.3 for the next update.
It may not match the long-term preferred direction, but it is simple and
obviously covers all cases.

NeilBrown

From: NeilBrown <neilb@suse.de>
Subject: Fix cookie decoding problem in NFS
Patch-mainline: no
References: bnc#678123

nfs3proc decode_dirent asks xdr_inline_decode to return a name
buffer and the cookie in a single request.
There could be padding between these, but if xdr_inline_decode
calls xdr_copy_to_scratch, it will assume the padding is at the end.

So in xdr_copy_to_scratch, round up 'nbytes' to we make don't
fail to return useful data.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

---
 net/sunrpc/xdr.c |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-2.6.37-openSUSE-11.4.orig/net/sunrpc/xdr.c
+++ linux-2.6.37-openSUSE-11.4/net/sunrpc/xdr.c
@@ -673,6 +673,11 @@ static __be32 *xdr_copy_to_scratch(struc
 	void *cpdest = xdr->scratch.iov_base;
 	size_t cplen = (char *)xdr->end - (char *)xdr->p;
 
+	/* some callers assume we return the full rounded-up
+	 * number of bytes.
+	 */
+	nbytes = XDR_QUADLEN(nbytes)*4;
+
 	if (nbytes > xdr->scratch.iov_len)
 		return NULL;
 	memcpy(cpdest, xdr->p, cplen);
