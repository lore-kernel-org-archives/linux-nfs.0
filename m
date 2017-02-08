Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753604AbdBHNnM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Feb 2017 08:43:12 -0500
Received: from smtp.corp.redhat.com (int-mx16.intmail.prod.int.phx2.redhat.com [10.5.11.28])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C966E804E5
        for <linux-nfs@vger.kernel.org>; Wed,  8 Feb 2017 13:42:15 +0000 (UTC)
Subject: Re: [libnfsidmap PATCH] libnfsidmap: nss_gss_princ_to_ids() and
 nss_gss_princ_to_grouplist() must strip the realm
To: Scott Mayhew <smayhew@redhat.com>
References: <1486505958-41507-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <d5913060-39f3-abf8-852d-650ac94fb82c@RedHat.com>
Date: Wed, 8 Feb 2017 08:42:15 -0500
MIME-Version: 1.0
In-Reply-To: <1486505958-41507-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2017 05:19 PM, Scott Mayhew wrote:
> nss_gss_princ_to_ids() and nss_gss_princ_to_grouplist() were hard-coded
> to call nss_getpwnam with the 'dostrip' arg set to 0, which is the
> opposite of what they should have had.  Note: there's no point making
> the decision to strip or not to strip configurable in these two
> functions.  Ideally both of these functions should be taking a
> gss_name_t instead of a char * for the principal, calling
> gss_localname() on that, and passing the result to nss_getpwnam... but
> that would require changes in both rpc.svcgssd and libgssglue (both of
> which have been deprecated for a while).
>
> Fixes: 4db1bb1 (libnfsidmap: add options to aid id mapping in multi domain environments)
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.

> ---
>  nss.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/nss.c b/nss.c
> index 67e657a..82799ce 100644
> --- a/nss.c
> +++ b/nss.c
> @@ -415,7 +415,7 @@ static int nss_gss_princ_to_ids(char *secname, char *princ,
>  		return -ENOENT;
>  	}
>  	/* XXX: this should call something like getgssauthnam instead? */
> -	pw = nss_getpwnam(princ, NULL, &err, 0);
> +	pw = nss_getpwnam(princ, NULL, &err, 1);
>  	if (pw == NULL) {
>  		err = -ENOENT;
>  		goto out;
> @@ -438,7 +438,7 @@ int nss_gss_princ_to_grouplist(char *secname, char *princ,
>  		goto out;
>  	/* XXX: not quite right?  Need to know default realm? */
>  	/* XXX: this should call something like getgssauthnam instead? */
> -	pw = nss_getpwnam(princ, NULL, &ret, 0);
> +	pw = nss_getpwnam(princ, NULL, &ret, 1);
>  	if (pw == NULL) {
>  		ret = -ENOENT;
>  		goto out;

