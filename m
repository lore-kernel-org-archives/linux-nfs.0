Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab1GLODG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 10:03:06 -0400
Message-ID: <4E1C5418.2000800@RedHat.com>
Date: Tue, 12 Jul 2011 10:03:04 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Masatake YAMATO <yamato@redhat.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] closing fd associated with /proc/fs/nfsd/export_features
References: <20110712.114700.814616059257545652.yamato@redhat.com>	<20110712104652.GA2162@fieldses.org>	<20110712.213817.1045173784079879730.yamato@redhat.com> <20110712.220109.419121694701200961.yamato@redhat.com>
In-Reply-To: <20110712.220109.419121694701200961.yamato@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/12/2011 09:01 AM, Masatake YAMATO wrote:
> Very sorry for posting again and again.
> fd shuold be closed even if read is failed.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index c250383..c96500f 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -784,8 +784,9 @@ struct export_features *get_export_features(void)
>  	fd = open(path, O_RDONLY);
>  	if (fd == -1)
>  		goto good;
> -	fd = read(fd, buf, 50);
> -	if (fd == -1)
> +	c = read(fd, buf, 50);
> +	close(fd);
> +	if (c == -1)
>  		goto err;
>  	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
>  	if (c != 2)
> 
Committed...

steved.
