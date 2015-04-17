Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbbDQSPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Apr 2015 14:15:07 -0400
Date: Fri, 17 Apr 2015 14:15:03 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.mountd: Remove duplicate and invalid secinfo setting
Message-ID: <20150417181503.GT63078@tonberry.usersys.redhat.com>
References: <552FB045.80604@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <552FB045.80604@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 16 Apr 2015, Kinglong Mee wrote:

> NFSD return reply of client's SECINFO_NO_NAME request with four
> security information number as, 1 1 0 0
> 
> It's caused by commit 4a1ad4aa30,
> "mountd: Enable all auth flavors on pseudofs exports"
> 
> This patch removes duplicate secinfo and invalid secinfo (zero).
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

This is because flav_map has both AUTH_UNIX/AUTH_SYS and
AUTH_NULL/AUTH_NONE.  I had discussed it with Steve, but since I didn't
observe any problems caused by it in my testing I just left them in.

Acked-by: Scott Mayhew <smayhew@redhat.com>

> ---
>  support/nfs/exports.c | 2 +-
>  utils/mountd/v4root.c | 3 +++
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 761a046..0aea6f1 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -408,7 +408,7 @@ int secinfo_addflavor(struct flav_info *flav, struct exportent *ep)
>  	struct sec_entry *p;
>  
>  	for (p=ep->e_secinfo; p->flav; p++) {
> -		if (p->flav == flav)
> +		if (p->flav == flav || p->flav->fnum == flav->fnum)
>  			return p - ep->e_secinfo;
>  	}
>  	if (p - ep->e_secinfo >= SECFLAVOR_COUNT) {
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index 429ebb8..d521725 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -69,6 +69,9 @@ set_pseudofs_security(struct exportent *pseudo, int flags)
>  	for (flav = flav_map; flav < flav_map + flav_map_size; flav++) {
>  		struct sec_entry *new;
>  
> +		if (!flav->fnum)
> +			continue;
> +
>  		i = secinfo_addflavor(flav, pseudo);
>  		new = &pseudo->e_secinfo[i];
>  
> -- 
> 2.3.5
> 

