Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387535AbeHAWrb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 18:47:31 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CFAC381100
        for <linux-nfs@vger.kernel.org>; Wed,  1 Aug 2018 20:59:53 +0000 (UTC)
Date: Wed, 1 Aug 2018 16:59:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Turn ENOATTR errors into ENODATA errrors
Message-ID: <20180801205951.GE19925@parsley.fieldses.org>
References: <20180801184052.21215-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180801184052.21215-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied, thanks.--b.

On Wed, Aug 01, 2018 at 02:40:52PM -0400, Steve Dickson wrote:
> The defining  of ENOATTR, which was an defined as ENODATA,
> was removed from the attr/xattr.h in modern releases
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  libnfs4acl/nfs4_acl_for_path.c | 2 +-
>  libnfs4acl/nfs4_set_acl.c      | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/libnfs4acl/nfs4_acl_for_path.c b/libnfs4acl/nfs4_acl_for_path.c
> index a51dc34..2fbf6c9 100644
> --- a/libnfs4acl/nfs4_acl_for_path.c
> +++ b/libnfs4acl/nfs4_acl_for_path.c
> @@ -94,7 +94,7 @@ static int nfs4_getxattr(const char *path, void *value, size_t size)
>  	if (res < -10000) {
>  		fprintf(stderr,"An internal NFS server error code (%d) was returned; this should never happen.\n",res);
>  	} else if (res < 0) {
> -		if (errno == ENOATTR)
> +		if (errno == ENODATA)
>  			fprintf(stderr,"Attribute not found on file: %s\n", path);
>  		else if (errno == EREMOTEIO)
>  		    fprintf(stderr,"An NFS server error occurred.\n");
> diff --git a/libnfs4acl/nfs4_set_acl.c b/libnfs4acl/nfs4_set_acl.c
> index b9edf2b..6c9b072 100644
> --- a/libnfs4acl/nfs4_set_acl.c
> +++ b/libnfs4acl/nfs4_set_acl.c
> @@ -55,7 +55,7 @@ int nfs4_set_acl(struct nfs4_acl *acl, const char *path)
>  	} else if (res < 0) {
>  		if (errno == EOPNOTSUPP)
>  			fprintf(stderr,"Operation to set ACL not supported.\n");
> -		else if (errno == ENOATTR)
> +		else if (errno == ENODATA)
>  			fprintf(stderr,"ACL Attribute not found on file.\n");
>  		else if (errno == EREMOTEIO)
>  			fprintf(stderr,"An NFS server error occurred.\n");
> -- 
> 2.17.1
> 
