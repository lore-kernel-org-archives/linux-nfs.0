Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754264AbcFHNMO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2016 09:12:14 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8070A7F6A7
	for <linux-nfs@vger.kernel.org>; Wed,  8 Jun 2016 13:12:13 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-49-78.rdu2.redhat.com [10.10.49.78])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u58DCCLP013971
	for <linux-nfs@vger.kernel.org>; Wed, 8 Jun 2016 09:12:13 -0400
Subject: Re: [PATCH] mount.nfs: added usage output when no arguemnts are given
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1465324504-8018-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <c8143711-0514-2232-da48-8d132e5cb530@RedHat.com>
Date: Wed, 8 Jun 2016 09:12:12 -0400
MIME-Version: 1.0
In-Reply-To: <1465324504-8018-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/07/2016 02:35 PM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/mount_libmount.c | 2 ++
>  1 file changed, 2 insertions(+)
Committed... 

steved.

> 
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index fa46d54..1f01f7f 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -208,6 +208,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  
>  	if (!spec || (*spec != '/' && strchr(spec,':') == NULL)) {
>  		nfs_error(_("%s: no mount point provided"), progname);
> +		umount_usage();
>  		return EX_USAGE;
>  	}
>  
> @@ -329,6 +330,7 @@ static int mount_main(struct libmnt_context *cxt, int argc, char **argv)
>  
>  	if (!mount_point) {
>  		nfs_error(_("%s: no mount point provided"), progname);
> +		mount_usage();
>  		goto err;
>  	}
>  	if (!spec) {
> 
