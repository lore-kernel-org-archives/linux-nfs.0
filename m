Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28839 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995Ab1CPNm5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 09:42:57 -0400
Subject: Re: Bug in xdr_copy_to_scratch???
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110316213642.360be61d@notabene.brown>
References: <20110316213642.360be61d@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 09:42:54 -0400
Message-ID: <1300282974.16266.33.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-16 at 21:36 +1100, NeilBrown wrote:
> Hi Trond,
> 
>  I'm currently trying to track down the cause of some very
> odd behaviour in readdir in openSUSE 11.4 (2.6.37.3 based).
> 
> I think it might be caused by xdr_copy_to_scratch not quite
> behaving correctly.
> 
> In particular, when it has to copy into the scratch buffer
> it only copies 'nbytes' bytes - which sounds reasonable but
> isn't.  It should copy XDR_QUADLEN(nbytes) words.
> 
> In particular, nfs3_decode_dirent contains:
> 
> 	p = xdr_inline_decode(xdr, entry->len + 8);
> 	if (unlikely(!p))
> 		goto out_overflow;
> 	entry->name = (const char *) p;
> 	p += XDR_QUADLEN(entry->len);
> 	entry->prev_cookie = entry->cookie;
> 	p = xdr_decode_hyper(p, &entry->cookie);
> 
> 
> where the cookie needs all of those last few bytes which
> we would only get by rounding nbytes up to a multiple of 4.
> 
> 
> I haven't developed or tested a fix yet, but as it is clearly a bug,
> I thought I would let you know before I call it a night.

Hi Neil,

I'm not sure I 100% agree that is a bug in xdr_copy_to_scratch(). I
think it is rather an artifact of the fact that xdr_inline_decode takes
a byte argument instead of a word argument, which means that combining
buffer lengths needs to done with care: my fault :-(.

To illustrate what I mean, consider the following snippet of xdr:

	p = xdr_decode_inline(xdr, len1 + len2);
	name1 = p;
	p += XDR_QUADLEN(len1);
	name2 = p;

No matter what we do in xdr_decode_inline(), there is no way we can
determine the true value of XDR_QUADLEN(len1)<<2 + XDR_QUADLEN(len2)<<2
if len1 and len2 are arbitrary buffer lengths.

So I'd argue that while we could fix this issue in xdr_copy_to_scratch
for this particular case, in reality nfs3_decode_dirent should not be
asking for a buffer of (entry->len + 8) bytes when it knows there is an
alignment issue due to the fact that the 8 cookie bytes follows the
string.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

