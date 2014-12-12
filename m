Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:48776 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759501AbaLLO6I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2014 09:58:08 -0500
Received: by mail-qa0-f53.google.com with SMTP id bm13so5274541qab.12
        for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 06:58:08 -0800 (PST)
Date: Fri, 12 Dec 2014 09:58:04 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Thomas Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH] nfs: guard fs/nfs/internal.h against multiple inclusion
Message-ID: <20141212095804.675912b9@tlielax.poochiereds.net>
In-Reply-To: <1418395818-22062-1-git-send-email-jlayton@primarydata.com>
References: <1418395818-22062-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Dec 2014 09:50:18 -0500
Jeff Layton <jlayton@primarydata.com> wrote:

> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> Cc: Thomas Haynes <thomas.haynes@primarydata.com>
> ---
>  fs/nfs/internal.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index efaa31c70fbe..ffef459f0b4f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -1,6 +1,8 @@
>  /*
>   * NFS internal definitions
>   */
> +#ifndef	__FS_NFS_INTERNAL_H

Gyah...sorry for the whitespace typo above. Want me to resend with that
tab turned into a space?

> +#define __FS_NFS_INTERNAL_H
>  
>  #include "nfs4_fs.h"
>  #include <linux/mount.h>
> @@ -629,3 +631,5 @@ static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
>  	return 0;
>  }
>  #endif
> +
> +#endif	/* __FS_NFS_INTERNAL_H */


-- 
Jeff Layton <jlayton@poochiereds.net>
