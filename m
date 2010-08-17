From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] Add server support to use of numeric strings for
 uid and gids.
Date: Tue, 17 Aug 2010 16:28:16 -0400
Message-ID: <1282076896.12506.3.camel@heimdal.trondhjem.org>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
	 <1282073925-18707-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40709 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab0HQU2W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 16:28:22 -0400
In-Reply-To: <1282073925-18707-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-08-17 at 15:38 -0400, Steve Dickson wrote:
> When a uid or gid does not map into the a domain and the
> new 'NumericIDs' variable is enabled in idmapd.conf, the server
> will send out numeric representations, strings without the
> @domain part, of the given id.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/idmapd/idmapd.c |   14 +++++++++++++-
>  1 files changed, 13 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index d6799c9..7f1291d 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -794,15 +794,22 @@ nfsopen(struct idmap_client *ic)
>  static void
>  idtonameres(struct idmap_msg *im)
>  {
> -	char domain[NFS4_MAX_DOMAIN_LEN];
> +	char domain[NFS4_MAX_DOMAIN_LEN], *numids;
>  	int ret = 0;
>  
>  	ret = nfs4_get_default_domain(NULL, domain, sizeof(domain));
> +	numids = conf_get_str("Mapping", "NumericIDs");
> +
>  	switch (im->im_type) {
>  	case IDMAP_TYPE_USER:
>  		ret = nfs4_uid_to_name(im->im_id, domain, im->im_name,
>  				sizeof(im->im_name));
>  		if (ret) {
> +			if (numids && strcasecmp(numids, "yes") == 0) {
> +				sprintf(im->im_name, "%d", im->im_id);
> +				ret=0;
> +				break;
> +			}
>  			if (strlen(nobodyuser) < sizeof(im->im_name))
>  				strcpy(im->im_name, nobodyuser);
>  			else
> @@ -813,6 +820,11 @@ idtonameres(struct idmap_msg *im)
>  		ret = nfs4_gid_to_name(im->im_id, domain, im->im_name,
>  				sizeof(im->im_name));
>  		if (ret) {
> +			if (numids && strcasecmp(numids, "yes") == 0) {
> +				sprintf(im->im_name, "%d", im->im_id);
> +				ret=0;
> +				break;
> +			}
>  			if (strlen(nobodygroup) < sizeof(im->im_name))
>  				strcpy(im->im_name, nobodygroup);
>  			else

Ditto...

Cheers
  Trond

