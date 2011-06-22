Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40240 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab1FVRPY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 13:15:24 -0400
Date: Wed, 22 Jun 2011 13:15:23 -0400
To: James Pearson <james-p@moving-picture.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] nfs-utils: remove possibly false statement from
 exports.man
Message-ID: <20110622171523.GA2284@fieldses.org>
References: <4E01CE91.50203@moving-picture.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E01CE91.50203@moving-picture.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Works for me, thanks.--b.

On Wed, Jun 22, 2011 at 12:14:25PM +0100, James Pearson wrote:
> A very minor change suggested by J. Bruce Fields
> <bfields@fieldses.org> to remove the statement that exporting to a
> single host or IP address is the "most common format" - as it
> probably isn't.
> 
> Signed-off-by: James Pearson <james-p@moving-picture.com>
> 
> --- a/utils/exportfs/exports.man        2011-06-22 11:37:41.228238000 +0100
> +++ b/utils/exportfs/exports.man        2011-06-22 11:38:51.012894000 +0100
> @@ -45,7 +45,7 @@
>  .SS Machine Name Formats
>  NFS clients may be specified in a number of ways:
>  .IP "single host
> -This is the most common format. You may specify a host either by an
> +You may specify a host either by an
>  abbreviated name recognized be the resolver, the fully qualified domain
>  name, or an IP address.
>  .IP "IP networks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
