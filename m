From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/9] user space NFSv2/v3 lock recovery, take 2
Date: Wed, 28 Apr 2010 12:21:01 -0400
Message-ID: <20100428162101.GE17491@fieldses.org>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46983 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755580Ab0D1QVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 12:21:01 -0400
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 27, 2010 at 02:58:09PM -0400, Chuck Lever wrote:
> I've trimmed the patches that Trond objected to last time, and, at
> Bruce's request, added documentation under
> Documentation/filesystems/nfs/ that describes the new API.

Thanks!

--b.

> As an
> addendum to this cover letter, the patch that adds the API
> documentation is first in this series.
> 
> ---
> 
> Chuck Lever (9):
>       lockd: Add "reboot" attribute to nsm_handles
>       lockd: Refactor nlm_host_rebooted()
>       lockd: Add /sys/fs/lockd/nsm_handle/*
>       lockd: Add /sys/fs/lockd/mon
>       lockd: Add attributes to /sys/fs/lockd/hosts/*/
>       lockd: Add /sys/fs/lockd/hosts/*
>       lockd: Add /sys/fs/lockd/hosts/
>       lockd: Add /sys/fs/lockd
>       lockd: Document new lockd user space API
> 
> 
>  Documentation/filesystems/nfs/00-INDEX            |    2 
>  Documentation/filesystems/nfs/lockd-sysfs-api.txt |  117 ++++++++
>  fs/lockd/host.c                                   |  312 ++++++++++++++++++++-
>  fs/lockd/mon.c                                    |  211 ++++++++++++++
>  fs/lockd/svc.c                                    |   31 ++
>  include/linux/lockd/lockd.h                       |    9 +
>  6 files changed, 659 insertions(+), 23 deletions(-)
>  create mode 100644 Documentation/filesystems/nfs/lockd-sysfs-api.txt
> 
> -- 
> Chuck Lever <chuck.lever@oracle.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
