Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61814 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333Ab1CQX1y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 19:27:54 -0400
Subject: Re: Bug in xdr_copy_to_scratch???
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1300404139.4621.1.camel@lade.trondhjem.org>
References: <20110316213642.360be61d@notabene.brown>
	 <1300282974.16266.33.camel@lade.trondhjem.org>
	 <20110317093838.0f15eb98@notabene.brown>
	 <1300384865.28305.27.camel@lade.trondhjem.org>
	 <20110318101608.34bb1117@notabene.brown>
	 <1300404139.4621.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 19:27:53 -0400
Message-ID: <1300404473.4621.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-03-17 at 19:22 -0400, Trond Myklebust wrote:
> On Fri, 2011-03-18 at 10:16 +1100, NeilBrown wrote:
> > On Thu, 17 Mar 2011 14:01:05 -0400 Trond Myklebust
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Thu, 2011-03-17 at 09:38 +1100, NeilBrown wrote:
> > > > We should probably submit a fix to 2.6.37-stable though.  For that it
> > > > is possibly simplest to tell xdr_decode_inline to round nbytes up to
> > > > a multiple of 4 - would you agree?
> > > 
> > > How about the following fix for 2.6.37 stable?
> > 
> > That is good for NFSv3, but NFSv2 has the same problem.  Code fragment is
> > 	p = xdr_inline_decode(xdr, entry->len + 4);
> > 	if (unlikely(!p))
> > 		goto out_overflow;
> > 	entry->name	  = (const char *) p;
> > 	p		 += XDR_QUADLEN(entry->len);
> > 	entry->prev_cookie	  = entry->cookie;
> > 	entry->cookie	  = ntohl(*p++);
> > 
> > so again we have the cookie after the name and they are decoded together.
> 
> Fair enough. I'll fix that one too.
> 

Here is the result.

BTW, those are the only cases we care about in -stable. There are no
other callers of xdr_set_scratch_buffer().

8<---------------------------------------------------------------------------------
