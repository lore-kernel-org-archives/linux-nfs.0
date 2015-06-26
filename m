Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbbFZNWa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jun 2015 09:22:30 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id CD737C79FB
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 13:22:30 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (unused [10.10.50.112] (may be forged))
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5QDMUS5019305
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 09:22:30 -0400
Message-ID: <558D5215.4010904@RedHat.com>
Date: Fri, 26 Jun 2015 09:22:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] mount.nfs manpage: Add nfsmount.conf
References: <1435241851-24530-1-git-send-email-steved@redhat.com> <1435241851-24530-2-git-send-email-steved@redhat.com>
In-Reply-To: <1435241851-24530-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/25/2015 10:17 AM, Steve Dickson wrote:
> Add nfsmount.conf to both the FILES and SEE ALSO
> sections
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/mount/mount.nfs.man | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
> index 15a82d5..0409c96 100644
> --- a/utils/mount/mount.nfs.man
> +++ b/utils/mount/mount.nfs.man
> @@ -80,10 +80,13 @@ file system table
>  .TP
>  .I /etc/mtab
>  table of mounted file systems
> -
> +.TP
> +.I /etc/nfsmount.conf
> +Configuration file for NFS mounts
>  .PD
>  .SH "SEE ALSO"
>  .BR nfs (5),
> +.BR nfsmount.conf (5),
>  .BR mount (8),
>  
>  .SH "AUTHOR"
> 
