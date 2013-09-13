Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f47.google.com ([209.85.214.47]:61325 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab3IMEmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Sep 2013 00:42:39 -0400
Message-ID: <52329471.7050001@gmail.com>
Date: Fri, 13 Sep 2013 06:28:33 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: mtk.manpages@gmail.com, linux-nfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH] access: fix outdated NFS information
References: <20130911202210.GB1462@fieldses.org>
In-Reply-To: <20130911202210.GB1462@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11.09.2013 22:22, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Note that NFS versions since version 3 support an "access" call so that
> the client doesn't have to guess permissions or id mapping on its own.
> 
> (See rfc 1813 sections 1.7 and 3.3.4.)

Thanks, Bruce. Applied.

Cheers,

Michael


> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  man2/access.2 |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/man2/access.2 b/man2/access.2
> index 6df68de..3bacab1 100644
> --- a/man2/access.2
> +++ b/man2/access.2
> @@ -209,9 +209,10 @@ Similarly, a DOS file may be found to be "executable," but the
>  call will still fail.
>  .PP
>  .BR access ()
> -may not work correctly on NFS filesystems with UID mapping enabled,
> +may not work correctly on NFSv2 filesystems with UID mapping enabled,
>  because UID mapping is done on the server and hidden from the client,
> -which checks permissions.
> +which checks permissions.  (NFS versions 3 and higher perform the check on
> +the server.)
>  Similar problems can occur to FUSE mounts.
>  .SH BUGS
>  In kernel 2.4 (and earlier) there is some strangeness in the handling of
> 

