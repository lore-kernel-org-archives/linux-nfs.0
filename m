From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/22] NFS: Move NFS client's IP address parser to
	nfs_common/
Date: Wed, 24 Dec 2008 23:47:45 -0500
Message-ID: <20081225044745.GD17998@fieldses.org>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net> <20081212215842.24332.47093.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54377 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487AbYLYErr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Dec 2008 23:47:47 -0500
In-Reply-To: <20081212215842.24332.47093.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 12, 2008 at 04:58:42PM -0500, Chuck Lever wrote:
> The kernel's NFS server also needs to parse presentation format IP
> addresses.  Since both the client and the server can reside in their own
> modules, move the parser logic to nfs_common, which can be used by either.

OK.  Nit:

> diff --git a/include/linux/nfs_addr_parse.h b/include/linux/nfs_addr_parse.h
> new file mode 100644
> index 0000000..484f511
> --- /dev/null
> +++ b/include/linux/nfs_addr_parse.h
> @@ -0,0 +1,32 @@
> +/*
> + * include/linux/nfs_addr_parse.h

We're trying not to add these path names to new files.

--b.
