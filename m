Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab3IXTY7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 15:24:59 -0400
Message-ID: <5241E726.6000100@RedHat.com>
Date: Tue, 24 Sep 2013 15:25:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: test_export shouldn't use invalid uid/gid
References: <20130919191203.GA29599@fieldses.org>
In-Reply-To: <20130919191203.GA29599@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/09/13 15:12, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Some newer kernels are rejecting -1 uid/gid.  Actually, worse--they're
> silently ignoring any attempt to cache such exports, thus preventing
> test_export from getting back the errors it needs.
> 
> And -1 wasn't a good choice anyway.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed...

steved.

> ---
>  utils/exportfs/exportfs.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 9f79541..4331697 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -420,7 +420,7 @@ static int test_export(char *path, int with_fsid)
>  	char buf[1024];
>  	int fd, n;
>  
> -	sprintf(buf, "-test-client- %s 3 %d -1 -1 0\n",
> +	sprintf(buf, "-test-client- %s 3 %d 65534 65534 0\n",
>  		path,
>  		with_fsid ? NFSEXP_FSID : 0);
>  	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
> 
