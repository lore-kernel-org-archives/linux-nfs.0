Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55074 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135Ab1CPKgv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 06:36:51 -0400
Date: Wed, 16 Mar 2011 21:36:42 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Bug in xdr_copy_to_scratch???
Message-ID: <20110316213642.360be61d@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Trond,

 I'm currently trying to track down the cause of some very
odd behaviour in readdir in openSUSE 11.4 (2.6.37.3 based).

I think it might be caused by xdr_copy_to_scratch not quite
behaving correctly.

In particular, when it has to copy into the scratch buffer
it only copies 'nbytes' bytes - which sounds reasonable but
isn't.  It should copy XDR_QUADLEN(nbytes) words.

In particular, nfs3_decode_dirent contains:

	p = xdr_inline_decode(xdr, entry->len + 8);
	if (unlikely(!p))
		goto out_overflow;
	entry->name = (const char *) p;
	p += XDR_QUADLEN(entry->len);
	entry->prev_cookie = entry->cookie;
	p = xdr_decode_hyper(p, &entry->cookie);


where the cookie needs all of those last few bytes which
we would only get by rounding nbytes up to a multiple of 4.


I haven't developed or tested a fix yet, but as it is clearly a bug,
I thought I would let you know before I call it a night.

Thanks,
NeilBrown
