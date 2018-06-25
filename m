Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60767 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751347AbeFYPh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:37:59 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9684E30C1105
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2018 15:37:59 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Fix minor memory leaks before return.
To: Kenneth Dsouza <kdsouza@redhat.com>, linux-nfs@vger.kernel.org
Cc: sorenson@redhat.com
References: <20180620162129.12692-1-kdsouza@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <71d23f25-2f6d-21a1-7b31-b85d4eeb7da5@RedHat.com>
Date: Mon, 25 Jun 2018 11:37:57 -0400
MIME-Version: 1.0
In-Reply-To: <20180620162129.12692-1-kdsouza@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/20/2018 12:21 PM, Kenneth Dsouza wrote:
> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>
> ---
>  support/junction/path.c            | 4 +++-
>  support/nfsidmap/nfsidmap_common.c | 4 +++-
>  2 files changed, 6 insertions(+), 2 deletions(-)
Committed... 

steved.
> 
> diff --git a/support/junction/path.c b/support/junction/path.c
> index 68a1d13..e74e4c4 100644
> --- a/support/junction/path.c
> +++ b/support/junction/path.c
> @@ -326,8 +326,10 @@ nsdb_posix_to_path_array(const char *pathname, char ***path_array)
>  			break;
>  		next = strchrnul(component, '/');
>  		length = (size_t)(next - component);
> -		if (length > 255)
> +		if (length > 255) {
> +			nsdb_free_string_array(result);
>  			return FEDFS_ERR_SVRFAULT;
> +		}
>  
>  		result[i] = strndup(component, length);
>  		if (result[i] == NULL) {
> diff --git a/support/nfsidmap/nfsidmap_common.c b/support/nfsidmap/nfsidmap_common.c
> index 5242c7e..f89b82e 100644
> --- a/support/nfsidmap/nfsidmap_common.c
> +++ b/support/nfsidmap/nfsidmap_common.c
> @@ -57,8 +57,10 @@ struct conf_list *get_local_realms(void)
>  			return NULL;
>  
>  		node->field = calloc(1, NFS4_MAX_DOMAIN_LEN);
> -		if (node->field == NULL)
> +		if (node->field == NULL) {
> +			free(node);
>  			return NULL;
> +		}
>  
>  		nfs4_get_default_domain(NULL, node->field, NFS4_MAX_DOMAIN_LEN);
>  		toupper_str(node->field);
> 
