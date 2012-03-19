Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31887 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030239Ab2CSOFk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 10:05:40 -0400
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the last realm
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1332160616-4522-1-git-send-email-steved@redhat.com>
Date: Mon, 19 Mar 2012 10:05:34 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <51B1F466-FB87-4764-850E-3936DA71F637@oracle.com>
References: <1332160616-4522-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 19, 2012, at 8:36 AM, Steve Dickson wrote:

> From: Juno Krahn <Juno.Krahn@gmail.com>
> 
> The list of local realms can be logged with a massage like the following:
>   rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
> Instead of printing a list of realms, only the last realm in the list is shown.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=804152
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>

The patch says "From: Juno Krahn" but the sign-off is from you.  Should you also have an SOB from Juno?

> ---
> libnfsidmap.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 57bb6c3..641d766 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -285,8 +285,9 @@ int nfs4_init_name_mapping(char *conffile)
> 			}
> 			buf = malloc(siz);
> 			if (buf) {
> +				*buf = 0;
> 				TAILQ_FOREACH(r, &local_realms->fields, link) {
> -					sprintf(buf, "'%s' ", r->field);
> +					sprintf(buf+strlen(buf), "'%s' ", r->field);
> 				}
> 				IDMAP_LOG(1, ("libnfsidmap: Realms list: %s", buf));
> 				free(buf);
> -- 
> 1.7.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




