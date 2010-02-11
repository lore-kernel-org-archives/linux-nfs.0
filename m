Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993Ab0BKQiJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 11:38:09 -0500
Date: Thu, 11 Feb 2010 11:38:35 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
Subject: Re: [pnfs] [PATCH] SQUASHME: pnfsd-exofs: Change layoutget return
	codes
Message-ID: <20100211163835.GA320@fieldses.org>
References: <1265737357-9405-1-git-send-email-andros@netapp.com> <4B726D4E.1000601@panasas.com> <4B728E38.4060008@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B728E38.4060008@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 10, 2010 at 12:45:12PM +0200, Boaz Harrosh wrote:
> On 02/10/2010 10:24 AM, Boaz Harrosh wrote:
> > 
> > Dependent on patch from Andy:
> > 	[PATCH 1/6] pnfsd: fix file system API layout_get error codes
> > 
> > Change codes to nfs4.1 codes
> > 
> > Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> 
> Rrrr I spoke to soon.
> 
> Andy, Benny
> This will not work, currently. All the nfserr_xxx constants are defined
> if fs/nfsd/nfsd.h. 
> (Why do they exist at all, why can't we use the client's definitions for these?)
> 
> At the minimum they need to move to include/linux/nfsd/export.h. But I say kill them
> and use these from include/linux/nfs4.h. Added bonus these are enums, so prototype
> of .layout_get() can change to return enum nfsstat4 and the compiler fixes all our
> bugs.
> 
> I'm posting a second patch that uses "enum nfsstat4" constants in exofs which will
> work just fine, but is really ugly on the documentation aspect of Andy's patch.
> 
> Bruce may I submit a patch that globally gets rid of all nfserr_* defines and uses
> NFS4ERR_* in their place?

And ditto for v2/v3 errors?

Note you'll also need to track down all the function return types and
the variables that hold errors, and change them from __be32 to something
else.  (Hopefully not int, as the distinction between nfs errors and
-ERRNO errors is useful.)

I agree that it would be better not to have two entirely separate sets
of errors defines.

It's a large change that will conflict with everything, but as it's
currently Benny that will probably have the most fixing-up to do I guess
I'd defer to him to weigh the pain caused by that.

--b.
