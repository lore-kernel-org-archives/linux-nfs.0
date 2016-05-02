Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbcEBOy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 10:54:28 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E7FDF80085
	for <linux-nfs@vger.kernel.org>; Mon,  2 May 2016 14:54:27 +0000 (UTC)
Subject: Re: [nfs-utils PATCH v2] exportfs: add the debug option
To: Scott Mayhew <smayhew@redhat.com>
References: <1461946437-2740-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <57276A23.7080404@RedHat.com>
Date: Mon, 2 May 2016 10:54:27 -0400
MIME-Version: 1.0
In-Reply-To: <1461946437-2740-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 29/04/16 12:13, Scott Mayhew wrote:
> Since calling xlog(D_GENERAL) will cause exportfs to exit with a status
> of 1, there really should be a way to see those messages for debugging
> purposes.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.
> ---
>  utils/exportfs/exportfs.c   | 7 +++++--
>  utils/exportfs/exportfs.man | 3 +++
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index a9151ff..5db348b 100644
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
>  		case 'f':
>  			force_flush = 1;
>  			break;
> @@ -878,6 +881,6 @@ error(nfs_export *exp, int err)
>  static void
>  usage(const char *progname, int n)
>  {
> -	fprintf(stderr, "usage: %s [-afhioruvs] [host:/path]\n", progname);
> +	fprintf(stderr, "usage: %s [-adfhioruvs] [host:/path]\n", progname);
>  	exit(n);
>  }
> diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
> index 75d952a..fdf9260 100644
> --- a/utils/exportfs/exportfs.man
> +++ b/utils/exportfs/exportfs.man
> @@ -88,6 +88,9 @@ appropriate export entry for the host given in
>  to be added to the kernel's export table.
>  .SH OPTIONS
>  .TP
> +.B \-d kind " or " \-\-debug kind
> +Turn on debugging. Valid kinds are: all, auth, call, general and parse.
> +.TP
>  .B -a
>  Export or unexport all directories.
>  .TP
> 
