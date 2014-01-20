Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:52499 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbaATXdB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jan 2014 18:33:01 -0500
Received: by mail-pd0-f178.google.com with SMTP id y13so7392394pdi.23
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 15:33:00 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/2] nfs4: fix discover_server_trunking use after free
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1390189537-9666-1-git-send-email-dros@primarydata.com>
Date: Mon, 20 Jan 2014 16:32:59 -0700
Cc: linux-nfs@vger.kernel.org
Message-Id: <D87D3ADC-94A0-438D-AADD-4139C70AE3B3@primarydata.com>
References: <1390189537-9666-1-git-send-email-dros@primarydata.com>
To: Adamson Weston Andros <dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 19, 2014, at 20:45, Weston Andros Adamson <dros@primarydata.com> wrote:

> If clp is new (cl_count = 1) and it matches another client in
> nfs4_discover_server_trunking, the nfs_put_client will free clp before
> ->cl_preserve_clid is set.
> 
> Cc: stable@vger.kernel.org # 3.7+
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
> fs/nfs/nfs4client.c | 7 ++++---
> 1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index c1b7a80..0f9b772 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -414,11 +414,12 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 	error = nfs4_discover_server_trunking(clp, &old);
> 	if (error < 0)
> 		goto error;
> -	nfs_put_client(clp);
> -	if (clp != old) {
> +
> +	if (clp != old)
> 		clp->cl_preserve_clid = true;
> +	nfs_put_client(clp);
> +	if (clp != old)
> 		clp = old;
> -	}
> 

Applied, but I cleaned it up by replacing the last 2 lines with an equivalent ‘return old’...

--
Trond Myklebust
Linux NFS client maintainer

