Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbbEDLhg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2015 07:37:36 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t44BbaDs003705
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 4 May 2015 07:37:36 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-59-87.rdu2.redhat.com [10.10.59.87])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t44BbZC3017172
	for <linux-nfs@vger.kernel.org>; Mon, 4 May 2015 07:37:35 -0400
Message-ID: <554759FE.4030902@RedHat.com>
Date: Mon, 04 May 2015 07:37:34 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap: make sure given arguments are valid
References: <1430417344-25020-1-git-send-email-steved@redhat.com> <1430417344-25020-2-git-send-email-steved@redhat.com>
In-Reply-To: <1430417344-25020-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/30/2015 02:09 PM, Steve Dickson wrote:
> Detect when a given argument is invalid. Log
> the error and exit gracefully
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/nfsidmap/nfsidmap.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index 5d62078..1f5ba67 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -323,7 +323,10 @@ int main(int argc, char **argv)
>  	}
>  	type = strtok(arg, ":");
>  	value = strtok(NULL, ":");
> -
> +    if (value == NULL) {
> +		xlog_err("Error: Null uid/gid value.");
> +		return 1;
> +	}
>  	if (verbose) {
>  		xlog_warn("key: 0x%lx type: %s value: %s timeout %ld",
>  			key, type, value, timeout);
> 
