Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757921Ab1FVWhz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 18:37:55 -0400
Message-ID: <4E026EBF.1080309@RedHat.com>
Date: Wed, 22 Jun 2011 18:37:51 -0400
From: Steve Dickson <SteveD@redhat.com>
To: James Pearson <james-p@moving-picture.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: remove possibly false statement from exports.man
References: <4E01CE91.50203@moving-picture.com>
In-Reply-To: <4E01CE91.50203@moving-picture.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/22/2011 07:14 AM, James Pearson wrote:
> A very minor change suggested by J. Bruce Fields <bfields@fieldses.org> to remove the statement that exporting to a single host or IP address is the "most common format" - as it probably isn't.
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
Committed...

steved.
