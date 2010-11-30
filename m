Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34666 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527Ab0K3TYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 14:24:42 -0500
Date: Tue, 30 Nov 2010 14:24:41 -0500
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/4] Allow the admin to turn off NFSv4 uid/gid
 mapping
Message-ID: <20101130192441.GD29091@fieldses.org>
References: <1291124043-5074-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291124043-5074-1-git-send-email-Trond.Myklebust@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 30, 2010 at 08:33:59AM -0500, Trond Myklebust wrote:
> The following patches allow the admin to turn off NFSv4 uid/gid mapping
> if mounting using AUTH_SYS security.

Maybe that should be "when a mountpoint allows only AUTH_SYS security"?

(Once we start allowing auth_flavor_len > 1, presumably we don't want to
change mappings depending on which flavor an individual getattr used!)

Also, maybe it's right, but I'm a little weirded about by the dependency
on the auth flavor.

--b.

> 
> Minor changes w.r.t. first revision:
>  - Added documentation in kernel-parameters.txt
>  - Print a warning if an NFSERR_BADOWNER causes us to turn idmapping on again
> 
> Trond Myklebust (4):
>   NFSv4: If the server sends us a numeric uid/gid then accept it
>   NFSv4: Send unmapped uid/gids to the server if the idmapper fails
>   NFSv4: cleanup idmapper functions to take an nfs_server argument
>   NFSv4: Send unmapped uid/gids to the server when using auth_sys
> 
>  Documentation/kernel-parameters.txt |    8 +++
>  fs/nfs/client.c                     |   16 ++++++
>  fs/nfs/idmap.c                      |   87 +++++++++++++++++++++++++++-------
>  fs/nfs/nfs4proc.c                   |   13 +++++-
>  fs/nfs/nfs4xdr.c                    |   18 +++----
>  include/linux/nfs_fs_sb.h           |    1 +
>  include/linux/nfs_idmap.h           |    8 ++--
>  7 files changed, 118 insertions(+), 33 deletions(-)
> 
> -- 
> 1.7.3.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
