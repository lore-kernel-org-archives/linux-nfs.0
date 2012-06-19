Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab2FSOMv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 10:12:51 -0400
Message-ID: <4FE08895.20705@RedHat.com>
Date: Tue, 19 Jun 2012 10:11:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?VmlsbGUgU2t5dHTDpA==?= <ville.skytta@iki.fi>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] idmapd.conf.5: Syntax fixes.
References: <1337546003-5218-1-git-send-email-ville.skytta@iki.fi>
In-Reply-To: <1337546003-5218-1-git-send-email-ville.skytta@iki.fi>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/20/2012 04:33 PM, Ville Skyttä wrote:
> Signed-off-by: Ville Skyttä <ville.skytta@iki.fi>
> ---
>  idmapd.conf.5 |   15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
Committed... sorry it took so long...

steved.
> 
> diff --git a/idmapd.conf.5 b/idmapd.conf.5
> index 9c7f1ae..7b9e762 100644
> --- a/idmapd.conf.5
> +++ b/idmapd.conf.5
> @@ -234,7 +234,6 @@ Number of seconds before timing out an LDAP request
>  .\" -------------------------------------------------------------------
>  .\"
>  .SH EXAMPLES
> -."
>  An example
>  .I /etc/idmapd.conf
>  file:
> @@ -266,7 +265,7 @@ johndoe@OTHER.DOMAIN.ORG = johnny
>  LDAP_server = ldap.domain.org
>  LDAP_base = dc=org,dc=domain
>  
> -.fo
> +.fi
>  .\"
>  .\" -------------------------------------------------------------------
>  .\" Additional sections
> @@ -275,11 +274,11 @@ LDAP_base = dc=org,dc=domain
>  .SH SEE ALSO
>  .BR idmapd (8)
>  .BR svcgssd (8)
> -.".SH COMPATIBILITY
> -.".SH STANDARDS
> -.".SH ACKNOWLEDGEMENTS
> -.".SH AUTHORS
> -.".SH HISTORY
> +.\".SH COMPATIBILITY
> +.\".SH STANDARDS
> +.\".SH ACKNOWLEDGEMENTS
> +.\".SH AUTHORS
> +.\".SH HISTORY
>  .SH BUGS
>  Report bugs to <nfsv4@linux-nfs.org>
> -.".SH CAVEATS
> +.\".SH CAVEATS
> -- 1.7.10.1 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html
> 
