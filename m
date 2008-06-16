From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Mon, 16 Jun 2008 08:39:53 -0400
Message-ID: <48565F19.10508@redhat.com>
References: <20080613213759.26929.patches@notabene> <1080613114215.27095@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36366 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656AbYFPMj5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 08:39:57 -0400
In-Reply-To: <1080613114215.27095@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:
> OCFS2 can return -ERESTARTSYS from write requests (and possibly
> elsewhere) if there is a signal pending.
>
> If nfsd is shutdown (by sending a signal to each thread) while there
> is still an IO load from the client, each thread could handle one last
> request with a signal pending.  This can result in -ERESTARTSYS
> which is not understood by nfserrno() and so is reflected back to
> the client as nfserr_io aka -EIO.  This is wrong.
>
> Instead, interpret ERESTARTSYS to mean "don't send a reply".
> The client will resend and - if the server is restarted - the write will
> (hopefully) be successful and everyone will be happy.
>
>   

Why not handle -ERESTARTSYS in the same fashion as -ETIMEDOUT, ie.
leading to a EJUKEBOX sort of error being returned if possible?

Simply not returning is a bad thing to do for anything other than
NFSv2.  It is especially bad for NFSv4.

       ps

> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./fs/nfsd/nfsproc.c |    1 +
>  1 file changed, 1 insertion(+)
>
> ----
> Funny how the shortest patches sometimes have the longest
> descriptions.
>
> The symptom that I narrowed down to this was:
>    copy a large file via NFS to an OCFS2 filesystem, and restart
>    the nfs server during the copy.
>    The 'cp' might get an -EIO, and the file will be corrupted -
>    presumably holes in the middle were writes appeared to fail.
>
> diff .prev/fs/nfsd/nfsproc.c ./fs/nfsd/nfsproc.c
> --- .prev/fs/nfsd/nfsproc.c	2008-06-13 21:31:53.000000000 +1000
> +++ ./fs/nfsd/nfsproc.c	2008-06-13 21:31:57.000000000 +1000
> @@ -614,6 +614,7 @@ nfserrno (int errno)
>  #endif
>  		{ nfserr_stale, -ESTALE },
>  		{ nfserr_jukebox, -ETIMEDOUT },
> +		{ nfserr_dropit, -ERESTARTSYS },
>  		{ nfserr_dropit, -EAGAIN },
>  		{ nfserr_dropit, -ENOMEM },
>  		{ nfserr_badname, -ESRCH },
>
> ### Diffstat output
>  ./fs/nfsd/nfsproc.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff .prev/fs/nfsd/nfsproc.c ./fs/nfsd/nfsproc.c
> --- .prev/fs/nfsd/nfsproc.c	2008-06-13 21:31:53.000000000 +1000
> +++ ./fs/nfsd/nfsproc.c	2008-06-13 21:31:57.000000000 +1000
> @@ -614,6 +614,7 @@ nfserrno (int errno)
>  #endif
>  		{ nfserr_stale, -ESTALE },
>  		{ nfserr_jukebox, -ETIMEDOUT },
> +		{ nfserr_dropit, -ERESTARTSYS },
>  		{ nfserr_dropit, -EAGAIN },
>  		{ nfserr_dropit, -ENOMEM },
>  		{ nfserr_badname, -ESRCH },
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

