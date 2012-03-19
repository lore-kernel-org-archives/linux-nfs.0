Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759297Ab2CSTpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 15:45:47 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2JJjkLa005476
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 19 Mar 2012 15:45:46 -0400
Message-ID: <4F678CE6.8080703@RedHat.com>
Date: Mon, 19 Mar 2012 15:45:42 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the last
 realm
References: <1332160616-4522-1-git-send-email-steved@redhat.com>
In-Reply-To: <1332160616-4522-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/19/2012 08:36 AM, Steve Dickson wrote:
> From: Juno Krahn <Juno.Krahn@gmail.com>
> 
> The list of local realms can be logged with a massage like the following:
>    rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
> Instead of printing a list of realms, only the last realm in the list is shown.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=804152
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved
> ---
>  libnfsidmap.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 57bb6c3..641d766 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -285,8 +285,9 @@ int nfs4_init_name_mapping(char *conffile)
>  			}
>  			buf = malloc(siz);
>  			if (buf) {
> +				*buf = 0;
>  				TAILQ_FOREACH(r, &local_realms->fields, link) {
> -					sprintf(buf, "'%s' ", r->field);
> +					sprintf(buf+strlen(buf), "'%s' ", r->field);
>  				}
>  				IDMAP_LOG(1, ("libnfsidmap: Realms list: %s", buf));
>  				free(buf);
