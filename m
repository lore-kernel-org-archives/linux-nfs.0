From: "Fletcher Mattox" <fletcher-NZpS4cJIG2HvQtjrzfazuQ@public.gmane.org>
Subject: Re: mail corruption with async mounts NFSv3
Date: Wed, 19 Mar 2008 23:49:12 -0500
Message-ID: <200803200449.m2K4nCRk019953@cs.utexas.edu>
References: <1205265265.15431.5.camel@heimdal.trondhjem.org>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from joejob.cs.utexas.edu ([128.83.120.81]:43757 "EHLO
	joejob.cs.utexas.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbYCTEtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Mar 2008 00:49:23 -0400
In-Reply-To: <1205265265.15431.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 11, Trond Myklebust writes:
> On Tue, 2008-03-11 at 13:59 -0500, Fletcher Mattox wrote:
> > Hi
> > 
> > We deliver mail via NFS to a NetApp file server.  After many trouble
> > free years, we are suddenly and frequently seeing corrupted mailboxes.
> > We usually see a series of NUL bytes (10 to 2000+) prepended to the
> > message (i.e. immediately in front of the From_ line).  Our local
> > delivery agent is procmail.  It is configured to lock files via
> > dotlock only, no kernel based file locking.  After obtaining a lock,
> > procmail does this, before writing:
> > 
> >         fd   = open(mailbox,O_WRONLY|O_APPEND|O_CREAT,perm);
> >         last = lseek(fd,(off_t)0,SEEK_END);
> > 
> > My experience with procmail has been positive.  It goes to great
> > trouble to do correct locking over NFS (within the limits of the
> > protocol, of course).
> > 
> > We use NFSv3 on a 2.6.19.1 kernel with this entry in /etc/mtab:
> 
> That is very likely to be the same problem as fixed in
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=5d47a35600270e7115061cb1320ee60ae9bcb6b8
> 
> AFAICR, all kernels after 2.6.17 were affected. Can you therefore see if
> the same patch applies to 2.6.19, and if it fixes your problem?

Yes!  That patch fixes the problem on both 2.6.19 and 2.6.22.8.  So now
the only mystery is why this problem did not manifest long ago.  We had
run both of those kernels for a long time without any trouble.  The only
change I can even remotely correlate was the addition of the ptpatch2008
module, designed to catch the recent vmsplice root exploit attempts.
But we removed that module, and the problem remained.  Oh well, at this
point I am just very happy to have a fix.  Thank you, Trond, for pointing
this out.

Fletcher
