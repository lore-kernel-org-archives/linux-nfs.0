Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756125Ab3KLTpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:45:34 -0500
Date: Tue, 12 Nov 2013 14:45:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
Message-ID: <20131112194529.GA26341@fieldses.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 12, 2013 at 02:04:05PM -0500, Anna Schumaker wrote:
> These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS is
> still under discussion with the IETF after my last series of patches, so I
> am holding off on resubmitting until after spec discussion dies down.
> 
> Questions?  Comments?  Thoughts?
> Anna
> 
> Anna Schumaker (3):
>   NFSD: Update error codes

I don't think I got this first patch.

>   NFSD: Create nfs v4.2 decode ops
>   NFSD: Implement SEEK

I'd like to be reassured the protocol is reasonably stable before we
commit this.  I haven't been following the ietf wg discussion closely.

And this should initially be disabled by default.  So, probably either:

	- Introduce a new NFSD_V4_SEEK option, or
	- Combine this and NFSD_V4_SECURITY_LABEL and this into a single
	  NFSD_V4_2 option.

And recommend "N" for now.

Probably the latter I guess, to be consistent with the client.  And
because otherwise we could end up with an awful lot of config options.

--b.

> 
>  fs/nfsd/nfs4proc.c   | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c    | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfsd.h       |  2 +-
>  fs/nfsd/xdr4.h       | 16 +++++++++++++++
>  include/linux/nfs4.h | 23 ++++++++++++++++++---
>  5 files changed, 151 insertions(+), 4 deletions(-)
> 
> -- 
> 1.8.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
