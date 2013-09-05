Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753931Ab3IEQCR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 12:02:17 -0400
Message-ID: <5228AB0A.4080906@RedHat.com>
Date: Thu, 05 Sep 2013 12:02:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] utils/exportfs/exports.man: quote command to preserve
 space
References: <1378164295-2032-1-git-send-email-rees@umich.edu>
In-Reply-To: <1378164295-2032-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/13 19:24, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/exportfs/exports.man | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed!

steved.

> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index bc1de73..58c0f66 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -39,7 +39,7 @@ the export name using a backslash followed by the character code as three
>  octal digits.
>  .PP
>  To apply changes to this file, run
> -.BR exportfs \-ra
> +.BR "exportfs \-ra"
>  or restart the NFS server.
>  .PP
>  .SS Machine Name Formats
