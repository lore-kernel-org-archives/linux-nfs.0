Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41416 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751354AbdGYUxQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 16:53:16 -0400
Date: Tue, 25 Jul 2017 16:53:15 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/11 V2] Removed a bunch random warnings
Message-ID: <20170725205315.GC15694@fieldses.org>
References: <20170721163806.15803-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 21, 2017 at 12:37:55PM -0400, Steve Dickson wrote:
> I upgraded to Fedora 26 and went to apply Neil's recent mount 
> patches and ended up seeing all these warning. 
> 
> These patches fix those warnings
> 
> v2: change a changelog that explicitly fixes a bug.
>     Changed a number of break statements into FALLTHRU comments.

Looks good to me, except for the obvious mistake on #3 (and one
whitespace nit).

Thanks!--b.

>     
> Steve Dickson (11):
>   rpcdebug.c: remove a warning
>   present_address: Fixed error path
>   atomicio: removed a warning
>   cache.c: removed a couple warning
>   nfsd.c: removed a few warnings
>   bldev_read_serial: removed a couple warnings
>   device-discovery.c: removed a warning
>   network.c: removed some warnings
>   nfsmount: remove a warning
>   nfs4mount: removed a warning
>   nfsdcltrack.c: remove a warning
> 
>  support/misc/tcpwrapper.c        | 1 +
>  support/nfs/atomicio.c           | 2 ++
>  tools/rpcdebug/rpcdebug.c        | 3 ++-
>  utils/blkmapd/device-discovery.c | 1 +
>  utils/blkmapd/device-inq.c       | 2 ++
>  utils/mount/network.c            | 5 +++++
>  utils/mount/nfs4mount.c          | 1 +
>  utils/mount/nfsmount.c           | 1 +
>  utils/mountd/cache.c             | 1 +
>  utils/nfsd/nfsd.c                | 3 +++
>  utils/nfsdcltrack/nfsdcltrack.c  | 1 +
>  11 files changed, 20 insertions(+), 1 deletion(-)
> 
> -- 
> 2.13.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
