Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657Ab2CSNMN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 09:12:13 -0400
Date: Mon, 19 Mar 2012 09:12:12 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the
 last realm
Message-ID: <20120319131212.GA21672@fieldses.org>
References: <1332160616-4522-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332160616-4522-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 19, 2012 at 08:36:56AM -0400, Steve Dickson wrote:
> From: Juno Krahn <Juno.Krahn@gmail.com>
> 
> The list of local realms can be logged with a massage like the following:
>    rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
> Instead of printing a list of realms, only the last realm in the list is shown.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=804152

Makes sense.  Could we also move this whole thing into a separate
function?:

	if (idmap_verbosity >= 1)
		log_local_realms(local_realms);

It's all just debugging code, no sense cluttering up the main
function....--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
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
> -- 
> 1.7.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
