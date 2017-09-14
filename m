Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751328AbdINRLg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 13:11:36 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 185007E426
        for <linux-nfs@vger.kernel.org>; Thu, 14 Sep 2017 17:11:36 +0000 (UTC)
Subject: Re: [PATCH RFC] nfs-utils: mount: handle EACCES during version
 negotiation
To: Frank Sorenson <sorenson@redhat.com>, linux-nfs@vger.kernel.org
References: <279c0751-8284-5289-3407-129dc9c9d3e8@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <f85953dd-c2eb-f6c7-d3d1-297be6b1b39e@RedHat.com>
Date: Thu, 14 Sep 2017 13:11:33 -0400
MIME-Version: 1.0
In-Reply-To: <279c0751-8284-5289-3407-129dc9c9d3e8@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/07/2017 11:14 AM, Frank Sorenson wrote:
> mount() can return EACCES for servers which permit 4.0
> but are configured not to allow 4.1  This is currently
> only handled by the default case, so these mounts fail
> without retrying a lower minor.
> 
> Add handling for EACCES to be retried with a lower
> minor version.
> 
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>
Committed... 

steved.
> ---
>  utils/mount/stropts.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 1d30d34..4401314 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -862,6 +862,9 @@ check_result:
>  	case EINVAL:
>  		/* A less clear indication that our client
>  		 * does not support NFSv4 minor version. */
> +	case EACCES:
> +		/* An unclear indication that the server
> +		 * may not support NFSv4 minor version. */
>  		if (mi->version.v_mode != V_SPECIFIC) {
>  			if (mi->version.minor > 0) {
>  				mi->version.minor--;
> 
