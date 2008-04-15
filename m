From: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: RFC/Patch: Make NFS Readahead tunable
Date: Tue, 15 Apr 2008 09:40:35 -0700 (PDT)
Message-ID: <78295.47709.qm@web32602.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32602.mail.mud.yahoo.com ([68.142.207.229]:47091 "HELO
	web32602.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754317AbYDOQkj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2008 12:40:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----
> From: Trond Myklebust <trond.myklebust@fys.uio.no>
> To: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-nfs list <linux-nfs@vger.kernel.org>
> Sent: Tuesday, April 15, 2008 6:12:32 PM
> Subject: Re: RFC/Patch: Make NFS Readahead tunable
> 
> 
> On Tue, 2008-04-15 at 06:39 -0700, Martin Knoblauch wrote:
> > Hi,
> > 
> >  while tracking down a very interesting interaction between Sun/SAM-FS and 
> Linux NFS clients, we found out that the value of NFS_MAX_READ_AHEAD is to 
> agressive/big for the specific use-case.
> > 
> >  For testing, instead of always recompiling the kernel with different values, 
> I came up with the following patch. It introduces a tunable  
> "/proc/sys/fs/nfs/nfs_ra_factor" with possible values between 0-15.
> > 
> >  Not sure whether it is actually a good thing to have. Better would be to set 
> the read-ahead factor per filesystem via a mount option.
> > 
> >  The patch is against 2.6.24. It applies with offsets against 2.6.25-rc9. In 
> case my mail client messes up the whitespace, the patch is also attached.
> 
> NFS_MAX_READ_AHEAD just sets an upper limit on the standard vfs/mm-level
> page readahead algorithm. If you need finer control over that readahead
> algorithm, then the kernel already has full support for the
> posix_fadvise() system call.
>

 But to use  posix_fadvise I would need control over the application. Correct? This is not given in the case I am actually dealing with. The NFS-server is Solaris-10/Sparc/SAM-FS. It turns out that *any* access to an "offline" file from a Linux-NFS client messes (and I mean messes) up the performance of the stager process if the read-ahead window is larger that 2 or three time rsize. Now - I have a pretty clear opinion of "who is at fault", but doing a band-aid on the Linux side may just be the easier thing, at least short/mid-term. Not sure how important the end-customer really is to the makers of SAM-FS.

 In general, of course controlling the readahead behaviour from the application is the better solution. anyway, the patch is simple enough to carry around.

Martin

> Cheers
>   Trond
> 
> 
> 


