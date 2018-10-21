Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E27FCECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 14:44:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 89B7E20869
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 14:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GiMAchLI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89B7E20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727676AbeJUW7C (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 18:59:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:55334 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727266AbeJUW7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 21 Oct 2018 18:59:02 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 618E820843;
        Sun, 21 Oct 2018 14:44:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540133068;
        bh=0/KzAKI71vuXcVtUpA5uNUrTn9R2O59xxTcb8OwdtRw=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=GiMAchLIcjFohAJTjISw337IkrIpe/qvv7XSED4zoeivT2ZfE2lQnjt8Yr1QvJlkA
         ta8CRy2+oMVDKkOB5H8HjNEhK2P6wqtAxwuuMrwhLzDtQVitFLZ4dObLIf09QCpX2V
         zZQ0jp6bCHHUD3KKwoyzxZiNrnQjh7Or9eDnegzc=
Message-ID: <4e5c759108926983cdbbdedf24995db84779ef2e.camel@kernel.org>
Subject: Re: [PATCH v1 03/11] NFS test for intra vs inter COPY
From:   Jeff Layton <jlayton@kernel.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Sun, 21 Oct 2018 10:44:14 -0400
In-Reply-To: <20181019152932.32462-4-olga.kornievskaia@gmail.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
         <20181019152932.32462-4-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs42.h | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> index 19ec38f8..5abff4d 100644
> --- a/fs/nfs/nfs42.h
> +++ b/fs/nfs/nfs42.h
> @@ -6,6 +6,7 @@
>  #ifndef __LINUX_FS_NFS_NFS4_2_H
>  #define __LINUX_FS_NFS_NFS4_2_H
>  
> +#include <linux/sunrpc/addr.h>
>  /*
>   * FIXME:  four LAYOUTSTATS calls per compound at most! Do we need to support
>   * more? Need to consider not to pre-alloc too much for a compound.
> @@ -21,4 +22,14 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *,
>  				   struct nfs42_layoutstat_data *);
>  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
>  
> +static inline bool nfs42_files_from_same_server(struct file *in,
> +						struct file *out)
> +{
> +	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
> +	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
> +
> +	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
> +				(struct sockaddr *)&c_out->cl_addr);
> +}
> +
>  #endif /* __LINUX_FS_NFS_NFS4_2_H */

What about trunking? If the addresses don't match, should you compare
cl_serverowner or something too? Or maybe just do that instead of
testing addresses?

It's usually best to add infrastructure like this in the same patch with
an initial caller so we can see how it's intended to be used. 
-- 
Jeff Layton <jlayton@kernel.org>

