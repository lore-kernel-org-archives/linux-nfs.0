From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/2 v4] nfs: return nfs4 compound header status on op
	header decoding error
Date: Wed, 16 Jul 2008 08:57:38 -0400
Message-ID: <1216213058.7786.2.camel@localhost>
References: <47F0F6AB.3030302@panasas.com>
	 <1206974900-368-1-git-send-email-bhalevy@panasas.com>
	 <1207002349.15341.15.camel@heimdal.trondhjem.org>
	 <47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>
	 <4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost>
	 <48277F7B.2060307@panasas.com>  <486D110F.1010608@panasas.com>
	 <1216159035.7981.70.camel@localhost>  <487DAF6F.10404@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56297 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753548AbYGPM5n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 08:57:43 -0400
In-Reply-To: <487DAF6F.10404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-07-16 at 11:21 +0300, Benny Halevy wrote:
> On Jul. 16, 2008, 0:57 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote: 
> > IOW: something like
> > 
> > 
> > @@static int decode_compound_hdr(
> > 	p += XDR_QUADLEN(hdr->taglen);
> > 	READ32(hdr->nops);
> > +	if (hdr->nops < 1)
> > +		return nfs4_stat_to_errno(hdr->status);
> > 	return 0;
> > }
> > 
> 
> This certainly provides a shortcut for the nops==0 case.
> However, it doesn't solve the OP_ILLEGAL case all other
> cases where xdr_inline_decode failed or opnum != expected,
> we can easily handle the OP_ILLEGAL case explicitly in
> decode_op_hdr.  Are you ok with the approach of
> carrying the hdr.status in xdr->status for decode_op_hdr
> use, or do you rather prefer to leave things as they are
> for the invalid cases and explicitly handle only the
> nops==0 and OP_ILLEGAL cases?

Why do we need to handle OP_ILLEGAL in the first place? This is the
client; it isn't supposed to send illegal operations...

Trond

