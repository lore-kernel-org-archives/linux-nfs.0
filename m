Return-Path: <SRS0=aRlV=NH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25BFFC46475
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 11:08:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C926720869
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 11:08:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="jl61KHN+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C926720869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728505AbeJ0Tsu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 15:48:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:59256 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728320AbeJ0Tst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 27 Oct 2018 15:48:49 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A6E5120856;
        Sat, 27 Oct 2018 11:08:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540638493;
        bh=D6xOQ1kCH/Ko1F0eh7Wu/QsIsTWIIhR9yU63oyebgPA=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=jl61KHN+Y5gdfe/tZXQd+h8W6eCwO9qBFNqM/4JVSJmXGG4dBX+IGRQ4Eckt/ALcn
         gb75GJ3AHYsdHCjuyfcSWgVZ/OrtP0ApCtXZwStCb8ZqLj8dHgQTlyWt/syhxGa208
         snw03xAmVixbvlZUkw/mC7i8rmn4z4KoaPBDTdDM=
Message-ID: <7ef50e2c6b11ae80518db75efc35b2f96c9e4d32.camel@kernel.org>
Subject: Re: [PATCH v4 11/11] NFS: replace cross device check in
 copy_file_range
From:   Jeff Layton <jlayton@kernel.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Date:   Sat, 27 Oct 2018 07:08:11 -0400
In-Reply-To: <20181026201057.36899-13-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
         <20181026201057.36899-13-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-26 at 16:10 -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Add a check to disallow cross file systems copy offload, both
> files are expected to be of NFS4.2+ type.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4file.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 2f31f30..344e9dd 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -139,8 +139,14 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  	nfs4_stateid *cnrs = NULL;
>  	ssize_t ret;
>  
> -	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +	if (file_in->f_op != &nfs4_file_operations)
>  		return -EXDEV;
> +	else {

nit: you don't really need the "else" here since the previous block
returns

> +		struct nfs_client *c_in =
> +			(NFS_SERVER(file_inode(file_in)))->nfs_client;
> +		if (c_in->cl_minorversion < 2)
> +			return -EXDEV;
> +	}
>  
>  	if (file_inode(file_in) == file_inode(file_out))
>  		return -EINVAL;

Looks fine though.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

