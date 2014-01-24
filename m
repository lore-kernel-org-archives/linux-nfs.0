Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:48265 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbaAXRCq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 12:02:46 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so3481641pab.12
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 09:02:40 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v2] nfs: don't attempt auth methods that require upcall unless we know that gssd is running
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1390567564-19241-1-git-send-email-jlayton@redhat.com>
Date: Fri, 24 Jan 2014 10:02:38 -0700
Cc: Weston Andros Adamson <dros@netapp.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <3A1E80DF-2F73-4A74-AE2C-E121DC7BEAD2@primarydata.com>
References: <1390567564-19241-1-git-send-email-jlayton@redhat.com>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 24, 2014, at 5:46, Jeff Layton <jlayton@redhat.com> wrote:

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

Big effing NACK.

This is exactly the kind of layering violation creep whereby the NFS layer ends up tracking more and more of the implementation details in the RPC authentication which made me hesitant about allowing gssd_running to be exported in the first place.

--
Trond Myklebust
Linux NFS client maintainer

