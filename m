Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44448 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365Ab3EUNKi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 09:10:38 -0400
Date: Tue, 21 May 2013 09:10:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: tigran.mkrtchyan@desy.de
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix typo in the man page
Message-ID: <20130521131036.GK14677@fieldses.org>
References: <1368970079-10028-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368970079-10028-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 19, 2013 at 03:27:59PM +0200, tigran.mkrtchyan@desy.de wrote:
> From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

Applied, thanks.--b.

> 
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  man/man5/nfs4_acl.5 | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man/man5/nfs4_acl.5 b/man/man5/nfs4_acl.5
> index 6b4fa88..3d5731f 100644
> --- a/man/man5/nfs4_acl.5
> +++ b/man/man5/nfs4_acl.5
> @@ -202,7 +202,7 @@ if either this
>  .I permission 
>  is set in the file/directory or if the delete-child 
>  .I permission
> -is set in its parent direcory.
> +is set in its parent directory.
>  .TP
>  .B D
>  delete-child - remove a file or subdirectory from within the given directory
> -- 
> 1.8.1.4
> 
