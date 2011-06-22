Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757921Ab1FVWgh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 18:36:37 -0400
Message-ID: <4E026E72.10906@RedHat.com>
Date: Wed, 22 Jun 2011 18:36:34 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benny Halevy <benny@tonian.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.39
References: <1308320500-9950-1-git-send-email-benny@tonian.com>
In-Reply-To: <1308320500-9950-1-git-send-email-benny@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/17/2011 10:21 AM, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <benny@tonian.com>
> ---
>  utils/nfsstat/nfsstat.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index a4a8034..8e6ca21 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -118,7 +118,7 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
>  	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
>  	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
>  	"setacl",    "fs_locations",
> -	"rel_lkowner",
> +	"rel_lkowner", "secinfo",
>  	/* nfsv4.1 client ops */
>  	"exchange_id",
>  	"create_ses",
> @@ -126,8 +126,8 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
>  	"sequence",
>  	"get_lease_t",
>  	"reclaim_comp",
> -	"getdevinfo",
>  	"layoutget",
> +	"getdevinfo",
>  	"layoutcommit",
>  	"layoutreturn",
>  	"getdevlist",
Committed...

steved.

