Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:47327 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbaDUP6z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 11:58:55 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so1919665igq.10
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 08:58:54 -0700 (PDT)
Message-ID: <1398095932.2891.26.camel@leira.trondhjem.org>
Subject: Re: [PATCH 34/70] NFSd: Fix atomicity of delegation counter
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 21 Apr 2014 11:58:52 -0400
In-Reply-To: <20140419155112.GA13579@infradead.org>
References: <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
	 <20140419155112.GA13579@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-04-19 at 08:51 -0700, Christoph Hellwig wrote:
> On Fri, Apr 18, 2014 at 02:44:28PM -0400, Trond Myklebust wrote:
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> I think at this point nfs4_lock_state() is always held so it's not
> quite a fix yet.  If that's not true the patch should be moved earlier
> in the series.

Fair enough...

> 
> > -static int num_delegations;
> > +static atomic_long_t num_delegations;
> 
> Why the switch from a int to an (atomic) long here?  If that was
> intentional it should be documented in the patch description.

It is intentional. The max_delegations that we're comparing to below is
of type 'unsigned long'.

> 
> > -	if (num_delegations > max_delegations)
> > -		return NULL;
> > +	atomic_long_inc(&num_delegations);
> > +	smp_mb__after_atomic_inc();
> > +	if (atomic_long_read(&num_delegations) > max_delegations)
> > +		goto out_dec;
> 
> Just use atomic_long_inc_return here.
> 
> > +out_dec:
> > +	atomic_long_dec(&num_delegations);
> > +	smp_mb__after_atomic_dec();
> 
> I can't see any point for having these barriers.

Agreed. I can't remember why I thought they were necessary.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


