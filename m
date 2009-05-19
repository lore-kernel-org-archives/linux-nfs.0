From: Neil Brown <neilb@suse.de>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Wed, 20 May 2009 08:39:47 +1000
Message-ID: <18963.13619.563465.804193@notabene.brown>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43190 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441AbZESW67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 18:58:59 -0400
In-Reply-To: message from Chuck Lever on Tuesday May 19
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday May 19, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> As part of IPv6 support for NFS, I've been looking at rpc.statd and sm- 
> notify.  IPv6 support touches so many parts of both, and the current  
> open-coded RPC request schedulers in both can't support netids without  
> major revision or replacement.  So I've decided to write a replacement  
> instead of grafting in support for IPv6 to the current implementation.
> 
> For many reasons I'm thinking of merging sm-notify and rpc.statd back  
> together.  The two were split only a few years ago, and it seems to me  
> that it was done to support SuSE's in-kernel statd, which has since  
> been effectively abandoned.
> 
> Having the two separated has ushered in a host of minor  
> complications.  Packaging and init-scripts are more complicated.  Both  
> executables have separate knowlege about /var/lib/nfs/{sm,sm.bak}.   
> There are two separate man pages that share a lot of the same content.
> 
> So, what do you think about folding sm-notify back into rpc.statd?   
> Steve suggested there may have been a customer issue that drove the  
> separation.  Do you have any recollection of the issues?
> 
> For the rest of the list: are there strong dependencies outside RH and  
> SuSE distributions that would require a separate sm-notify  
> executable?  Any other issues?

While the separation of sm-notify was presumably driven by the suse
in-kernel statd, that wasn't the reason that I copied the idea in
nfs-utils.

sm-notify and statd really have two very different tasks.

sm-notify :
   - is a 'client' for the "SM" protocol.
   - must be run at boot time, and after that is not needed.


statd :
   - is a 'server' for the "SM" protocol.
   - only needs to be running when either nfsd is running or an 
     nfs mount which supports locks is active

Thus I feel they are conceptually quite distinct.

It is probably true that they could share a slab of code, and putting
that code in a common .c file would make a lot of sense.

I am not strongly against re-uniting them.  However before doing that,
I think it would be a good idea to collect a list of the problems that
would be solved by unifying them, and the asking the question: is
unifying them the only or best solution to these problems.

Thanks,
NeilBrown
