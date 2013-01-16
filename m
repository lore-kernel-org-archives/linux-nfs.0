Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756238Ab3APUli (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2013 15:41:38 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0GKf2TN016182
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2013 15:41:38 -0500
Message-ID: <50F71049.9050905@RedHat.com>
Date: Wed, 16 Jan 2013 15:40:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.idmapd: Ignore open failures in dirscancb()
References: <1357152473-4260-1-git-send-email-steved@redhat.com>
In-Reply-To: <1357152473-4260-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/01/13 13:47, Steve Dickson wrote:
> From: David Jeffery <djeffery@redhat.com>
> 
> The daemon "rpc.idmapd" scans the /var/lib/nfs/rpc_pipefs/nfs/ directory
> periodically looking for NFS client mounts to communicate to. The daemon
> tried to open communication with a client mount but it disappeared in
> between looking for directory entries and opening them. NFS mount was
> umounted just before rpc.idmapd tried to communicate with it. This
> behavior is usually seen when autofs is configured on the system.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/idmapd/idmapd.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index 9d66225..beba9c4 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -424,7 +424,8 @@ dirscancb(int UNUSED(fd), short UNUSED(which), void *data)
>  			    pipefsdir, ents[i]->d_name);
>  
>  			if ((ic->ic_dirfd = open(path, O_RDONLY, 0)) == -1) {
> -				xlog_warn("dirscancb: open(%s): %s", path, strerror(errno));
> +				if (verbose > 0)
> +					xlog_warn("dirscancb: open(%s): %s", path, strerror(errno));
>  				free(ic);
>  				goto out;
>  			}
> 
