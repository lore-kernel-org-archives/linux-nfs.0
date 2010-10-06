From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils typo
Date: Tue, 5 Oct 2010 22:34:18 -0400
Message-ID: <FA907009-83DF-4B4D-9687-B5879EB96B97@oracle.com>
References: <20101005194304.GA7508@merit.edu>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
	peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59972 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758266Ab0JFCfL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 22:35:11 -0400
In-Reply-To: <20101005194304.GA7508-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 5, 2010, at 3:43 PM, Jim Rees wrote:

> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
> utils/mount/nfs.man |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index d2a4c5f..0667b3a 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -619,7 +619,7 @@ in such cases.
> .BI nfsvers= n
> The NFS protocol version number used to contact the server's NFS service.
> If the server does not support the requested version, the mount request fails.
> -If this option is not specified, the client negociate a suitable version with
> +If this option is not specified, the client negotiate a suitable version with

negotiate(s)?

> the server, trying version 4 first, version 3 second, and version 2 last.
> .TP 1.5i
> .BI vers= n
> -- 
> 1.7.0.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



