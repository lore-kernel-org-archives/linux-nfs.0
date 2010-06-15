From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] pnfsd: Add IP address validation to
	nfsd4_set_pnfs_dlm_device()
Date: Tue, 15 Jun 2010 10:55:50 -0400
Message-ID: <20100615145550.GC17437@fieldses.org>
References: <20100614200001.GJ2745@fieldses.org> <4C168C6C.5060508@panasas.com> <4C16C4AD.9000906@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eanderle@umich.edu, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50428 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757939Ab0FOOzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:55:52 -0400
In-Reply-To: <4C16C4AD.9000906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 14, 2010 at 08:09:17PM -0400, Benny Halevy wrote:
> On Jun. 14, 2010, 16:09 -0400, Benny Halevy <bhalevy@panasas.com> wrote:
> > On 2010-06-14 16:00, J. Bruce Fields wrote:
> >> From: Eric Anderle <eanderle@umich.edu>
> >>
> >> We should catch errors in the format at the time the list is given to
> >> the kernel, rather than just returning garbage to the client and letting
> >> the client fail.
> >>
> >> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> >> ---
> >>  fs/nfsd/nfs4pnfsdlm.c |   29 +++++++++++++++++++++++------
> >>  1 files changed, 23 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> >> index 1cf1b69..b6d9f23 100644
> >> --- a/fs/nfsd/nfs4pnfsdlm.c
> >> +++ b/fs/nfsd/nfs4pnfsdlm.c
> >> @@ -26,6 +26,7 @@
> >>  #include <linux/nfsd/debug.h>
> >>  #include <linux/nfsd/nfs4pnfsdlm.h>
> >>  #include <linux/nfsd/nfs4layoutxdr.h>
> >> +#include <linux/sunrpc/clnt.h>
> >>  
> >>  #include "nfsfh.h"
> >>  #include "nfsd.h"
> >> @@ -87,6 +88,24 @@ out:
> >>  	return ret;
> >>  }
> >>  
> >> +bool nfsd4_validate_pnfs_dlm_device(char *ds_list, int len, int *num_ds)
> > 
> > Is "len" used?
> 
> Merged at pnfs-all-2.6.35-rc3-2010-06-14
> len parameter removed.

Thanks.

--b.
