Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756822AbeAHOPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 09:15:51 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A26BD6B236
        for <linux-nfs@vger.kernel.org>; Mon,  8 Jan 2018 14:15:51 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Update svcgssd so that it builds
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <1514985934.3551.2.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <9fc1f09a-75be-9513-9e78-d1ebb77d2309@RedHat.com>
Date: Mon, 8 Jan 2018 09:15:50 -0500
MIME-Version: 1.0
In-Reply-To: <1514985934.3551.2.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/03/2018 08:25 AM, Justin Mitchell wrote:
> Since a15bd948 the --enable-svcgss option no longer builds
> as svcgssd references functions which were changed at that time.
> Fix those, and other function changes since then.
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/svcgssd.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
> index 3514ae1..23f0c0b 100644
> --- a/utils/gssd/svcgssd.c
> +++ b/utils/gssd/svcgssd.c
> @@ -63,6 +63,8 @@
>  #include "err_util.h"
>  #include "conffile.h"
>  
> +struct state_paths etab;
> +
>  void
>  sig_die(int signal)
>  {
> @@ -101,7 +103,7 @@ main(int argc, char *argv[])
>  	char *principal = NULL;
>  	char *s;
>  
> -	conf_init(NFS_CONFFILE); 
> +	conf_init_file(NFS_CONFFILE);
>  
>  	s = conf_get_str("svcgssd", "principal");
>  	if (!s)
> 
