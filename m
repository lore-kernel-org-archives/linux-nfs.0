Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38050 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967071AbeFSQ5Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Jun 2018 12:57:24 -0400
Subject: Re: [PATCH v3 2/2] nfs(5): update clientaddr value options
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
References: <20180605192909.27578-1-kolga@netapp.com>
 <20180605192909.27578-2-kolga@netapp.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <df111fc8-3be1-0cac-5f52-363046e8bc80@RedHat.com>
Date: Tue, 19 Jun 2018 12:57:23 -0400
MIME-Version: 1.0
In-Reply-To: <20180605192909.27578-2-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/05/2018 03:29 PM, Olga Kornievskaia wrote:
> Document the use of IPv4/IPv6_ANY address as values to the clientaddr
> as a way to tell the server that the client does not want delegations.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Committed... 

steved.
> ---
>  utils/mount/nfs.man | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index bd1508c..9ee9bd9 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -835,6 +835,9 @@ to perform NFS version 4.0 callback requests against
>  files on this mount point. If  the  server is unable to
>  establish callback connections to clients, performance
>  may degrade, or accesses to files may temporarily hang.
> +Can specify a value of IPv4_ANY (0.0.0.0) or equivalent
> +IPv6 any address which will signal to the NFS server that
> +this NFS client does not want delegations.
>  .IP
>  If this option is not specified, the
>  .BR mount (8)
> 
