Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55864 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbaLTSCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Dec 2014 13:02:44 -0500
Date: Sat, 20 Dec 2014 13:02:43 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
Message-ID: <20141220180243.GA10273@fieldses.org>
References: <20141217212159.GA11517@fieldses.org>
 <5492C710.20104@googlemail.com>
 <20141218144856.GA18179@fieldses.org>
 <alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
 <20141218151914.GB18179@fieldses.org>
 <pan.2014.12.18.15.42.53@googlemail.com>
 <20141218163254.GF18179@fieldses.org>
 <549303FC.9090604@googlemail.com>
 <20141218170653.GG18179@fieldses.org>
 <54932EA5.9090803@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <54932EA5.9090803@googlemail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 18, 2014 at 08:44:37PM +0100, Holger Hoffstätte wrote:
> On 12/18/14 18:06, J. Bruce Fields wrote:
> > Whoops, now I see, the server-side trace has the same problem, I
> > just overlooked it the first time.
> 
> Excellent, so we know it's the server's fault. Really would have been odd to not have it in the server trace.
> 
> >> ..in order to rule out a mistake on my part with the two separate
> >> runs (which prevents correlated analysis) I was just about to boot
> >> the server back into 3.18.1 and re-run both client- and server-side
> >> traces simultaneously. However I have to head out for a bit first;
> >> will post that later today.
> > 
> > So this might still be interesting, but it's not a high priority.
> 
> Then I guess I'll better keep my feet still and don't muddle the waters further, looks like you found what you need. If you still need it just holler.
> 
> Let me know if there's anything I can do to help/patch/test!

Gah.  Does this fix it?

A struct xdr_stream at a page boundary might point to the end of one
page or the beginning of the next, and I'm guessing xdr_truncate_encode
wasn't prepared to handle the former.

This happens if the readdir entry that would have exceeded the client's
dircount/maxcount limit would have ended exactly on a 4k page boundary,
and inspection of the trace shows you're hitting exactly that case.

If this does the job then I'll go figure out how to make this logic less
ugly....

--b.

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 1cb61242e55e..32910b91d17c 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -630,6 +630,9 @@ void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
 
 	new = buf->page_base + buf->page_len;
 	old = new + fraglen;
+	/* XXX: HACK: */
+	if (xdr->p == page_address(*xdr->page_ptr) + PAGE_SIZE)
+		xdr->page_ptr++;
 	xdr->page_ptr -= (old >> PAGE_SHIFT) - (new >> PAGE_SHIFT);
 
 	if (buf->page_len) {
