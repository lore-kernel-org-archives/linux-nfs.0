Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933555AbeBMOXz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 09:23:55 -0500
Subject: Re: [PATCH] git should ignore the generated nfsref executable
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
References: <20180208171515.13080.3776.stgit@manet.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <91c49d97-87eb-8228-708a-2f649b9352c2@RedHat.com>
Date: Tue, 13 Feb 2018 09:23:54 -0500
MIME-Version: 1.0
In-Reply-To: <20180208171515.13080.3776.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/08/2018 12:15 PM, Chuck Lever wrote:
> Clean up.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  .gitignore |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/.gitignore b/.gitignore
> index f17db9c..692ab0e 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -72,6 +72,7 @@ tests/nsm_client/nlm_sm_inter_clnt.c
>  tests/nsm_client/nlm_sm_inter_svc.c
>  tests/nsm_client/nlm_sm_inter_xdr.c
>  utils/nfsidmap/nfsidmap
> +utils/nfsref/nfsref
>  systemd/nfs-server-generator
>  systemd/rpc-pipefs-generator
>  systemd/nfs-config.service
> 
