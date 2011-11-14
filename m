Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753324Ab1KNVLl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 16:11:41 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAELBeap022792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:11:41 -0500
Message-ID: <4EC1840B.5080800@RedHat.com>
Date: Mon, 14 Nov 2011 16:11:39 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.idmapd: Sections in idmapd.conf are ignored.
References: <1321283020-15730-1-git-send-email-steved@redhat.com>
In-Reply-To: <1321283020-15730-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/14/2011 10:03 AM, Steve Dickson wrote:
> In the parsing routine, conf_parse_line(), a string
> is not being null terminated which is causing
> section of the config file to be ignored.
> 
> https://bugzilla.linux-nfs.org/show_bug.cgi?id=205
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  support/nfs/conffile.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index fa0dc6b..3990578 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -256,13 +256,14 @@ conf_parse_line(int trans, char *line, size_t sz)
>  			val++, j++;
>  		if (*val)
>  			i = j;
> -		section = malloc(i);
> +		section = malloc(i+1);
>  		if (!section) {
>  			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
>  						(unsigned long)i);
>  			return;
>  		}
>  		strncpy(section, line, i);
> +		section[i] = '\0';
>  
>  		if (arg) 
>  			free(arg);
