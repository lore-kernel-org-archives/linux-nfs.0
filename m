From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/1] nfs : Define NFS_FS only when FILE_LOCKING is
	enabled
Date: Fri, 30 Jan 2009 10:06:40 -0500
Message-ID: <20090130150640.GA22347@fieldses.org>
References: <ea11fea30901290722s5d9fe1b4y8f6142bcd137eb2@mail.gmail.com> <ea11fea30901292038h5810bde4lf83470332b6b72c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Manish Katiyar <mkatiyar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55420 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756721AbZA3PGm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 10:06:42 -0500
In-Reply-To: <ea11fea30901292038h5810bde4lf83470332b6b72c9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 30, 2009 at 10:08:11AM +0530, Manish Katiyar wrote:
> Hi Bruce,
> 
> I didn't see this one merged in your 2.6.30 tree. Was it missed (since
> I had sent it to wrong list by mistake). Please ignore if already
> merged.

It should be there at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.30

--b.

> 
> 
> Below patch enables NFS_FS only when FILE_LOCKING is enabled.
> 
> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
> ---
>  fs/nfs/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 36fe20d..e93151e 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -1,6 +1,7 @@
>  config NFS_FS
>        tristate "NFS client support"
>        depends on INET
> +       depends on FILE_LOCKING
>        select LOCKD
>        select SUNRPC
>        select NFS_ACL_SUPPORT if NFS_V3_ACL
> --
> 1.5.4.3
> 
> 
> Thanks -
> Manish
