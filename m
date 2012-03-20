Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528Ab2CTT4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 15:56:09 -0400
Date: Tue, 20 Mar 2012 15:56:07 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] RFC: export options for junctions
Message-ID: <20120320195607.GD1431@fieldses.org>
References: <20120302195451.18167.81861.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120302195451.18167.81861.stgit@degas.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 02, 2012 at 02:54:51PM -0500, Chuck Lever wrote:
> At Connectathon, I ran my FedFS-enabled client in a guest environment
> with NAT networking.  This made the source port for my NFS connections
> unprivileged.
> 
> Attempting to access a junction on my test server failed with a
> "client insecure" error on the server, even if I specified the
> "insecure" export option on the parent export.  I added "insecure" to
> the default junction export options, and this fixed the problem.
> 
> Bruce suggested, however, that the correct way to address this is to
> have junctions inherit the export options of their parent.  I don't
> see a direct way to do this, so I'm posting this patch as a
> conversation starter.

I think you want to do something like the search in
nfs-utils/utils/mountd/cache.c:lookup_export()--look for the export with
the longest matching path, and copy options from that.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mountd/cache.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ac9cdbd..35bc2e9 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -853,7 +853,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
>  			ptr += len;
>  		} else {
>  			if (last_path == NULL)
> -				len = snprintf(ptr, remaining, "refer=%s@%s",
> +				len = snprintf(ptr, remaining, "insecure,refer=%s@%s",
>  							rootpath, server);
>  			else
>  				len = snprintf(ptr, remaining, ":%s@%s",
> 
