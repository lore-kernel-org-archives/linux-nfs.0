Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469AbbDBRWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 13:22:13 -0400
Message-ID: <551D7AC2.4050607@RedHat.com>
Date: Thu, 02 Apr 2015 13:22:10 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: linux-nfs@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Cyril Brulebois <kibi@debian.org>
Subject: Re: [PATCH 1/2] nfs-utils: cross-reference nfsd.7 from nfsd.8 and
 vice versa
References: <1427876624-28066-1-git-send-email-hch@lst.de>
In-Reply-To: <1427876624-28066-1-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/01/2015 04:23 AM, Christoph Hellwig wrote:
> From: Cyril Brulebois <kibi@debian.org>
> 
> It'd be nice if one could notice nfsd(7) when reading nfsd(8) and the
> other way round, without having to have to resort to “dpkg -L $pkg” to
> figure out what documentation is available.
> ---
>  utils/exportfs/nfsd.man | 1 +
>  utils/nfsd/nfsd.man     | 1 +
>  2 files changed, 2 insertions(+)
Committed...

steved.

> 
> diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
> index 47b73be..0c516fa 100644
> --- a/utils/exportfs/nfsd.man
> +++ b/utils/exportfs/nfsd.man
> @@ -196,6 +196,7 @@ classes of tracing to be enabled.  Consult the kernel header files to
>  find out what number correspond to what tracing.
>  
>  .SH SEE ALSO
> +.BR nfsd (8),
>  .BR rpc.nfsd (8),
>  .BR exports (5),
>  .BR nfsstat (8),
> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
> index be21ed4..3ba847e 100644
> --- a/utils/nfsd/nfsd.man
> +++ b/utils/nfsd/nfsd.man
> @@ -121,6 +121,7 @@ address family combinations that are marked visible in the
>  database.
>  
>  .SH SEE ALSO
> +.BR nfsd (7),
>  .BR rpc.mountd (8),
>  .BR exports (5),
>  .BR exportfs (8),
> 
