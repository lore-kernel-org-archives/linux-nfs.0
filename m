Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753640AbcFHKwe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2016 06:52:34 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9D32E7D0C2
	for <linux-nfs@vger.kernel.org>; Wed,  8 Jun 2016 10:52:33 +0000 (UTC)
Subject: Re: [PATCH] mount.nfs: added usage output when no arguemnts are given
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1465324504-8018-1-git-send-email-steved@redhat.com>
From: Freeman Zhang <zhezhang@redhat.com>
Message-ID: <5757F8E9.7080705@redhat.com>
Date: Wed, 8 Jun 2016 18:52:25 +0800
MIME-Version: 1.0
In-Reply-To: <1465324504-8018-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2016 02:35 AM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>   utils/mount/mount_libmount.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index fa46d54..1f01f7f 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -208,6 +208,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>   
>   	if (!spec || (*spec != '/' && strchr(spec,':') == NULL)) {
>   		nfs_error(_("%s: no mount point provided"), progname);
> +		umount_usage();
>   		return EX_USAGE;
>   	}
>   
> @@ -329,6 +330,7 @@ static int mount_main(struct libmnt_context *cxt, int argc, char **argv)
>   
>   	if (!mount_point) {
>   		nfs_error(_("%s: no mount point provided"), progname);
> +		mount_usage();
>   		goto err;
>   	}
>   	if (!spec) {
Reasonable. Ack.
Acked-by: Freeman Zhang <zhezhang@redhat.com>
