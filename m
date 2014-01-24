Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34349 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbaAXPJS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 10:09:18 -0500
Received: by mail-ig0-f176.google.com with SMTP id j1so2778316iga.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 07:09:17 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v2] nfs: don't attempt auth methods that require upcall unless we know that gssd is running
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <1390567564-19241-1-git-send-email-jlayton@redhat.com>
Date: Fri, 24 Jan 2014 10:09:14 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <48E963DA-50E1-4911-A4CB-E6A30AC09101@monkey.org>
References: <1390567564-19241-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Jeff,

This makes sense to me.

-dros


On Jan 24, 2014, at 7:46 AM, Jeff Layton <jlayton@redhat.com> wrote:

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
> fs/nfs/nfs4proc.c | 8 ++++++++
> 1 file changed, 8 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 15052b8..937a05a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2900,6 +2900,14 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> 	} else {
> 		/* no flavors specified by user, try default list */
> 		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> +			/*
> +			 * Don't attempt to upcall with the default list
> +			 * unless we know that gssd is running.
> +			 */
> +			if (flav_array[i] > RPC_AUTH_MAXFLAVOR &&
> +			    !gssd_running(server->nfs_client->cl_net))
> +				continue;
> +
> 			status = nfs4_lookup_root_sec(server, fhandle, info,
> 						      flav_array[i]);
> 			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
> -- 
> 1.8.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

