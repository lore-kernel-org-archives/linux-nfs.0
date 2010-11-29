From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] libnfs.a: fix a bug when parse section's arg
Date: Mon, 29 Nov 2010 11:06:45 -0500
Message-ID: <4CF3CF95.7090506@RedHat.com>
References: <4CD36FE7.1010100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6815 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab0K2QGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 11:06:49 -0500
In-Reply-To: <4CD36FE7.1010100@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/04/2010 10:45 PM, Mi Jinlong wrote:
> When parsing section's arg at configure file, the pointer 
> should stop when fetch ']', and give the warning message.
> 
> ---
>  support/nfs/conffile.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 24640f4..798e5f3 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -271,9 +271,9 @@ conf_parse_line(int trans, char *line, size_t sz)
>  		if (ptr == NULL)
>  			return;
>  		line = ++ptr;
> -		while (*ptr && *ptr != '"')
> +		while (*ptr && *ptr != '"' && *ptr != ']')
>  			ptr++;
> -		if (*ptr == '\0') {
> +		if (*ptr == '\0' || *ptr == ']') {
>  			xlog_warn("config file error: line %d: "
>   				"non-matched '\"', ignoring until next section", ln);
>  		}  else {
Committed...

steved.
