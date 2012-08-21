Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758453Ab2HUVZW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 17:25:22 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7LLPMDx006928
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 17:25:22 -0400
Received: from pad.fieldses.org (vpn-11-55.rdu.redhat.com [10.11.11.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q7LLPMtj026485
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 17:25:22 -0400
Date: Tue, 21 Aug 2012 17:25:21 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/14] nfsd: allow configuring nfsd to listen on 5-digit
 ports
Message-ID: <20120821212521.GB28143@pad.fieldses.org>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
 <1345582652-18476-7-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1345582652-18476-7-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Second time we've seen a mistake like that recently, so maybe we really
should add the string-length-of-a-number macro.

--b.

On Tue, Aug 21, 2012 at 04:57:24PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Note a 16-bit value can require up to 5 digits.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfsctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 89be13c..e41a08ff 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -712,7 +712,7 @@ static ssize_t __write_ports_addxprt(char *buf)
>  	int port, err;
>  	struct net *net = &init_net;
>  
> -	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
> +	if (sscanf(buf, "%15s %5u", transport, &port) != 2)
>  		return -EINVAL;
>  
>  	if (port < 1 || port > USHRT_MAX)
> -- 
> 1.7.9.5
> 
