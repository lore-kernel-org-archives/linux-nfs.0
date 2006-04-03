From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH] knfsd: Correct reserved reply space for read requests.
Date: Mon, 3 Apr 2006 13:45:49 +1000
Message-ID: <17456.39533.920110.831056@cse.unsw.edu.au>
References: <17456.30621.579579.483287@cse.unsw.edu.au>
	<OF8E2FDC8A.57540B9E-ON88257145.0010DA43-88257145.0012B720@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964832AbWDCDrj@vger.kernel.org>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: message from Marc Eshel on Sunday April 2
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sunday April 2, eshel@almaden.ibm.com wrote:
> nfs-admin@lists.sourceforge.net wrote on 04/02/2006 06:17:17 PM:
> 
> > On Thursday March 30, eshel@almaden.ibm.com wrote:
> > > Hi Neil
> > > Can we use this opportunity to change NFSSVC_MAXBLKSIZE from 32K to 
> 64K to 
> > > match RPCSVC_MAXPAYLOAD. It makes real difference in I/O performance 
> (we 
> > > will still be saving half the space we used to allocate :).
> > > Thanks, Marc. 
> > 
> > Maybe... but why not 128K ??
>  
> Yes, It would be nice to be able to match the Linux client side that can 
> go to 1MB. 
> 
> > There is certainly room to increase NFSSVC_MAXBLKSIZE, but I feel that
> > it needs to be done together with a more detailed look at consequences
> > in the network layer, particularly TCP window sizes.  I wouldn't mind
> > making a CONFIG_ tunable without that detailed look, but making it a
> > fixed change I feel less comfortable about.
> 
> Like you said it will need match more work to do it right and also not 
> waste space for all RPC request to which the maximum possible size is 
> allocated up front. But until than way not take advantage of this minor 
> change that can give us significant performance improvement. I run with 
> NFSSVC_MAXBLKSIZE set to 64K (the only change I made) and saw 10%-15% 
> improvement for NFS reads. Is there anyone out there that is looking at 
> making this improvement ?

It was a fairly soft reservation of space, and we never actually tried
to use it all.
I don't see a clear problem with just making the change you mention,
but until I have thought through the implications (or until someone
else has and convinces me) I don't feel comfortable making the change.

It's on my todo list, but that doesn't promise a lot :-(
If someone else wants to try to convince me it is safe, and mention
tcp window sizes a couple of time, I'll probably be happy with it.

NeilBrown
