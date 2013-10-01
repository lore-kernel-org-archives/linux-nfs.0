Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856Ab3JAWMD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 18:12:03 -0400
Date: Tue, 1 Oct 2013 18:12:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 08/49] pnfsd: layout verify
Message-ID: <20131001221200.GA30994@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220824-13047-1-git-send-email-bhalevy@primarydata.com>
 <20130927144448.GD9946@pad.fieldses.org>
 <52480C18.6070105@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52480C18.6070105@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 29, 2013 at 02:16:40PM +0300, Benny Halevy wrote:
> On 2013-09-27 17:44, J. Bruce Fields wrote:
> > On Thu, Sep 26, 2013 at 02:40:24PM -0400, Benny Halevy wrote:
> >>  	return 0;
> >>  
> >>  }
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 419572f..576b635 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -41,6 +41,7 @@
> >>  #include "vfs.h"
> >>  #include "current_stateid.h"
> >>  #include "netns.h"
> >> +#include "pnfsd.h"
> >>  
> >>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> >>  #include <linux/security.h>
> >> @@ -1109,6 +1110,44 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >>  	return status == nfserr_same ? nfs_ok : status;
> >>  }
> >>  
> >> +#if defined(CONFIG_PNFSD)
> >> +static __be32
> >> +nfsd4_layout_verify(struct super_block *sb, struct svc_export *exp,
> >> +		    unsigned int layout_type)
> >> +{
> >> +	int status, type;
> >> +
> >> +	/* check to see if pNFS  is supported. */
> >> +	status = nfserr_layoutunavailable;
> >> +	if (exp && exp->ex_pnfs == 0) {
> > 
> > Can this really be called with exp == NULL?  If so don't you want to
> > fail that as well?
> 
> It is called with exp == NULL from nfsd4_getdevinfo where it shouldn't
> cause an error return.

Looking through the sbid code, this is making me uncomfortable.

Among other things this allows you to perform getdeviceinfo even against
filesystems that aren't exported.  Maybe that's not awful, but.

Also the sbid hash holds all these pointers to superblocks, but does it
take a reference to them anywhere?  I can't see it, in which case
there's a crash waiting to happen here if one of them is unmounted.

I'm inclined to think these should be referencing exports, not
superblocks.

--b.
