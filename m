Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:49567 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbcFVFJB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 01:09:01 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: NeilBrown <neilb@suse.com>
CC: Dickson Steve <SteveD@redhat.com>, Howard Guo <hguo@suse.com>,
        NFS List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs.man: clarify effect of 'retry' option.
Date: Wed, 22 Jun 2016 05:08:01 +0000
Message-ID: <7031616D-5483-494A-A749-28D8861CDB29@primarydata.com>
References: <87por9lufn.fsf@notabene.neil.brown.name>
In-Reply-To: <87por9lufn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 22, 2016, at 00:27, NeilBrown <neilb@suse.com> wrote:
> 
> 
> 
> The total timeout for a "mount" attempt to an non-responsive server
> will always be a multiple of time a single mount attempt in the kernel takes,
> which for TCP defaults to about 4 minutes.
> The documentation for the "retry" option seems to suggest that this can be used
> to set a maximum but it really sets a time after which to stop retrying.
> The total can be as much as "retry" plus the time for a single attempt.
> 
> So clarify the documentation a bit, and also note that retrans
> defaults are different for UDP and TCP:
>   #define NFS_DEF_UDP_RETRANS	(3)
>   #define NFS_DEF_TCP_RETRANS	(2)
> 
> Reported-by: Howard Guo<hguo@suse.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index e541cdc95cb1..fab24f898f64 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -391,6 +391,13 @@ is 2 minutes, and the default value for background mounts is 10000 minutes
> If a value of zero is specified, the
> .BR mount (8)
> command exits immediately after the first failure.
> +.IP
> +Note that the total timeout will always be a multiple of the time
> +determined by the
> +.BR timeo
> +and
> +.BR retrans
> +options, which by default will be 30 minutes.

How do we get to 30 minutes?

