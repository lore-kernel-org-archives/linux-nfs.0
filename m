Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928AbcD2PJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 11:09:32 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BB1D9345599
	for <linux-nfs@vger.kernel.org>; Fri, 29 Apr 2016 15:09:31 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] exportfs: add the debug option
To: Scott Mayhew <smayhew@redhat.com>
References: <1461936356-26727-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5723792A.8020408@RedHat.com>
Date: Fri, 29 Apr 2016 11:09:30 -0400
MIME-Version: 1.0
In-Reply-To: <1461936356-26727-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/29/2016 09:25 AM, Scott Mayhew wrote:
> Since calling xlog(D_GENERAL) will cause exportfs to exit with a status
> of 1, there really should be a way to see those messages for debugging
> purposes.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  utils/exportfs/exportfs.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index a9151ff..a5eb156 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -108,11 +108,14 @@ main(int argc, char **argv)
>  	xlog_stderr(1);
>  	xlog_syslog(0);
>  
> -	while ((c = getopt(argc, argv, "afhio:ruvs")) != EOF) {
> +	while ((c = getopt(argc, argv, "ad:fhio:ruvs")) != EOF) {
>  		switch(c) {
>  		case 'a':
>  			f_all = 1;
>  			break;
> +		case 'd':
> +			xlog_sconfig(optarg, 1);
> +			break;
I'm all for doing this but there needs to be an
usage() update and man page update. For the man
page update, just rip the verbiage out of the
mountd man page since they are the same.

steved.
 
>  		case 'f':
>  			force_flush = 1;
>  			break;
> 
