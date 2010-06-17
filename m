From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] pnfsd: Add ability to clear pnfs dlm device ds list
Date: Thu, 17 Jun 2010 17:17:11 -0400
Message-ID: <20100617211711.GS29639@fieldses.org>
References: <1276804400.1796.8.camel@Berlin> <4C1A8E45.3090004@panasas.com> <4C1A8E91.8060102@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eanderle@umich.edu, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40503 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759930Ab0FQVRN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 17:17:13 -0400
In-Reply-To: <4C1A8E91.8060102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 05:07:29PM -0400, Benny Halevy wrote:
> On Jun. 17, 2010, 17:06 -0400, Benny Halevy <bhalevy@panasas.com> wrote:
> > On Jun. 17, 2010, 15:53 -0400, Eric Anderle <eanderle@umich.edu> wrote:
> >> Added the ability to clear the pnfs dlm device ds list. Before, we
> >> checked to make sure the list wasn't empty; this is accomplished by
> >> examining the character after the ':' in the passed-in string. By
> >> modifying this check, an empty list is considered valid, and everything
> >> just works.
> >>
> > 
> > Eric, a couple technical nits:
> > One, please sign-off your patches.
> > This is the fact convention that the author also signs off his/her
> > own patches.

Note: see "120 Sign your work" under Documentation/SubmittingPatches to
understand what you're agreeing to.  (Basically, it's just certifying
that the work you're submitting is really yours.)

> > 
> >> ---
> >>  fs/nfsd/nfs4pnfsdlm.c |    4 +---
> >>  1 files changed, 1 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> >> index 40f9b84..befec4f 100644
> >> --- a/fs/nfsd/nfs4pnfsdlm.c
> >> +++ b/fs/nfsd/nfs4pnfsdlm.c
> >> @@ -160,17 +160,15 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device,
> >> int len)
> >>  
> >>         err = -EINVAL;
> >>         bufp += len + 1;
> >> -       if (bufp >= endp)
> >> +       if (bufp > endp)
> > 
> > Second, please make sure not to convert tabs to spaces...
...
> 
> Oh, and beware of long line wrapping...

The instructions for Evolution in Documentation/email-clients.txt may
help.

--b.
