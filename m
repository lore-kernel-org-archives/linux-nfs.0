From: Neil Brown <neilb@suse.de>
Subject: Re: Wondering about NLM_HOST_MAX ... doesn't anyone understand this code?
Date: Fri, 8 Feb 2008 13:02:22 +1100
Message-ID: <18347.47150.621022.745013@notabene.brown>
References: <18346.31720.497379.823879@notabene.brown>
	<8D04CC58-DF98-47FB-872A-792976AA7316@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55182 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbYBHCCX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 21:02:23 -0500
In-Reply-To: message from Chuck Lever on Thursday February 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday February 7, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> I don't have a problem with removing the variant expiry behavior --  
> in fact, I think it might be better if NLM host garbage collection  
> was done only under memory pressure.

Cool, thanks.

> >
> > -	if (++nrhosts > NLM_HOST_MAX)
> > -		next_gc = 0;
> > -
> 
> AFAICT this is the only place where nrhosts is bumped.  So you should  
> either get rid of nrhosts all together, or leave in a ++nrhosts;  
> somewhere.
> 

It is still used for a sanity check, and would be needed (I think) if
we introduced a memory-pressure handler, so I'll leave it there and
restore the "++nrhosts" - thanks for catching that.

Thanks,
NeilBrown
