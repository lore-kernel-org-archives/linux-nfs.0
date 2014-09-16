Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863AbaIPNah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Sep 2014 09:30:37 -0400
Message-ID: <54183B7A.3060209@RedHat.com>
Date: Tue, 16 Sep 2014 09:30:34 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: ensure that preferred_realm is non-NULL before
 passing it to strcmp
References: <1410194154-25567-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410194154-25567-1-git-send-email-jlayton@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/08/2014 12:35 PM, Jeff Layton wrote:
> It's possible for "preferred_realm" to be NULL, in which case we
> don't want to pass it to strcmp. Other places that use this variable
> test whether it's NULL first -- we need to do the same here.
> 
> This should fix the gssd crash reported here:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=1108615
> 
> Reported-by: Brian J. Murrell <brian@interlinx.bc.ca>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Committed... 

steved.

> ---
>  utils/gssd/krb5_util.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 8369fdf0ed27..f1ebc0d09731 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -876,7 +876,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  	i = 0;
>  	realm = realmnames[i];
>  
> -	if (strcmp (realm, preferred_realm) != 0) {
> +	if (preferred_realm && strcmp (realm, preferred_realm) != 0) {
>  		realm = preferred_realm;
>  		/* resetting the realmnames index */
>  		i = -1;
> 
