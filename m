Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751347AbeFYPgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:36:50 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6EB61C0587D1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2018 15:36:50 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-218.phx2.redhat.com [10.3.116.218])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 37E9C7D4B0
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2018 15:36:50 +0000 (UTC)
Subject: Re: [PATCH] nfsdcltrack: getopt_long() fails on a non x86_64 archs
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180624183619.59562-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <4b24a9c7-a019-2a7c-1fdd-dd9d2b9a4c20@RedHat.com>
Date: Mon, 25 Jun 2018 11:36:49 -0400
MIME-Version: 1.0
In-Reply-To: <20180624183619.59562-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/24/2018 02:36 PM, Steve Dickson wrote:
> getopt_long() returns an int, not char, which
> matters on non-x86_64 archs since a char is
> signed on x86_64 arch but unsigned on other
> archs.
> 
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1551903
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  utils/nfsdcltrack/nfsdcltrack.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
> index 76b06d2..b45a904 100644
> --- a/utils/nfsdcltrack/nfsdcltrack.c
> +++ b/utils/nfsdcltrack/nfsdcltrack.c
> @@ -553,7 +553,7 @@ find_cmd(char *cmdname)
>  int
>  main(int argc, char **argv)
>  {
> -	char arg;
> +	int arg;
>  	char *val;
>  	int rc = 0;
>  	char *progname, *cmdarg = NULL;
> 
