Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:38116 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756410Ab2CTQGs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 12:06:48 -0400
Subject: Re: [PATCH] RFC: export options for junctions
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120302195451.18167.81861.stgit@degas.1015granger.net>
Date: Tue, 20 Mar 2012 12:06:41 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <2F0C0694-430C-446A-8C92-FB0D6A3D61F9@oracle.com>
References: <20120302195451.18167.81861.stgit@degas.1015granger.net>
To: "J. Bruce Fields" <bfields@redhat.com>, Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bump.

Any ideas?  Bueller?  Anyone?


On Mar 2, 2012, at 2:54 PM, Chuck Lever wrote:

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
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> utils/mountd/cache.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ac9cdbd..35bc2e9 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -853,7 +853,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
> 			ptr += len;
> 		} else {
> 			if (last_path == NULL)
> -				len = snprintf(ptr, remaining, "refer=%s@%s",
> +				len = snprintf(ptr, remaining, "insecure,refer=%s@%s",
> 							rootpath, server);
> 			else
> 				len = snprintf(ptr, remaining, ":%s@%s",
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




