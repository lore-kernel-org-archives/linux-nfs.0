Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466AbaAXMpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 07:45:07 -0500
Date: Fri, 24 Jan 2014 07:45:03 -0500
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: dros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't attempt auth methods that require upcall
 unless we know that gssd is running
Message-ID: <20140124074503.05ab18e0@tlielax.poochiereds.net>
In-Reply-To: <1390565368-17597-1-git-send-email-jlayton@redhat.com>
References: <1390565368-17597-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Jan 2014 07:09:28 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> Currently, if the server lists krb5 as an allowed auth method, but gssd isn't
> running, you'll get the infamous "AUTH_GSS upcall failed" message, even if
> you didn't request sec=krb5.
> 
> This is because nfs4_find_root_sec() establishes a default list of auth
> methods to try when the admin didn't supply one, and that list contains
> AUTH_GSS methods first. Skip those methods if gssd isn't running since
> they won't succeed anyway.
> 
> Cc: Weston Andros Adamson <dros@netapp.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 15052b8..468a581 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2900,6 +2900,13 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>  	} else {
>  		/* no flavors specified by user, try default list */
>  		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> +			/*
> +			 * Don't attempt to upcall with the default list
> +			 * unless we know that gssd is running.
> +			 */
> +			if (!gssd_running(server->nfs_client->cl_net))
> +				continue;
> +
>  			status = nfs4_lookup_root_sec(server, fhandle, info,
>  						      flav_array[i]);
>  			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)

Eep! Wrong patch. I'll resend. Sorry for the noise...

-- 
Jeff Layton <jlayton@redhat.com>
