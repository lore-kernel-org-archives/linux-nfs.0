Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbbFZNWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jun 2015 09:22:07 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id C57733D1D7E
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 13:22:07 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (unused [10.10.50.112] (may be forged))
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5QDM7jt018999
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 09:22:07 -0400
Message-ID: <558D51FE.5020608@RedHat.com>
Date: Fri, 26 Jun 2015 09:22:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs manpage: Add nfsmount.conf
References: <1435241851-24530-1-git-send-email-steved@redhat.com>
In-Reply-To: <1435241851-24530-1-git-send-email-steved@redhat.com>
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
>  utils/mount/nfs.man | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index fe4f9b1..e541cdc 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -1706,6 +1706,9 @@ with the mount options already saved on disk for the NFS server mounted at /mnt.
>  .TP 1.5i
>  .I /etc/fstab
>  file system table
> +.TP 1.5i
> +.I /etc/nfsmount.conf
> +Configuration file for NFS mounts
>  .SH BUGS
>  Before 2.4.7, the Linux NFS client did not support NFS over TCP.
>  .P
> @@ -1735,6 +1738,7 @@ such as security negotiation, server referrals, and named attributes.
>  .BR mount.nfs (5),
>  .BR umount.nfs (5),
>  .BR exports (5),
> +.BR nfsmount.conf (5),
>  .BR netconfig (5),
>  .BR ipv6 (7),
>  .BR nfsd (8),
> 
