Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932356AbdHWS7b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Aug 2017 14:59:31 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C5C08883D9
        for <linux-nfs@vger.kernel.org>; Wed, 23 Aug 2017 18:59:31 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] idmapd: daemonize earlier
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20170807190914.7422-1-smayhew@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a81dc663-9e0e-1c8d-d1da-fc6a2cbb7a8b@RedHat.com>
Date: Wed, 23 Aug 2017 14:59:31 -0400
MIME-Version: 1.0
In-Reply-To: <20170807190914.7422-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2017 03:09 PM, Scott Mayhew wrote:
> daemon_init() calls closeall() to close any "unneeded" file descriptors.
> This causes the following issue with idmapd on systems that are
> configured to have SSSD handle local users and groups:
> 
> 1. During startup, rpc.idmapd calls getpwnam("nobody") and
>    getgrnam("nobody")
> 2. sss_nss_mc_get{pw,gr}nam from libnss_sss open the cache files for
>    users and groups and store the fd's in a struct sss_cli_mc_ctx.  The
>    passwd cache is fd 3 and the group cache is fd 4.
> 3. idmapd calls daemon_init() which sets fd's 0, 1, and 2 to /dev/null
>    and fd 3 to the write end of the pipe that the child uses to report
>    it's startup status.  It then closes all fd's >= 4.
> 4. idmapd then calls event_init() which leads to epoll_create1() which
>    returns 4 as the epoll fd.
> 6. An NFSv4 mount request comes in from a client, triggering an nfsdcb
>    callback.
> 7. idmapd calls getgrgid_r() which leads to a call to
>    sss_nss_check_header() which determines that the cache needs to be
>    reinitialized.  sss_nss_mc_destroy_ctx() is called, which closes the
>    ctx->fd which now corresponds to the epoll file rather than the group
>    cache file.
> 8. event_dispatch() calls epoll_wait() with epfd=4, and -EBADF is
>    returned.  idmapd logs the following error and exits with  a nonzero
>    status:
> 
> rpc.idmapd[650]: main: event_dispatch returns errno 9 (Bad file descriptor)
> 
> Moving the deamon_init() call so that it happens before get{pw,gr}nam()
> fixes this.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.
> ---
>  utils/idmapd/idmapd.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index c12e878..4cbe148 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -312,6 +312,8 @@ main(int argc, char **argv)
>  
>  	strncat(pipefsdir, "/nfs", sizeof(pipefsdir));
>  
> +	daemon_init(fg);
> +
>  	if ((pw = getpwnam(nobodyuser)) == NULL)
>  		errx(1, "Could not find user \"%s\"", nobodyuser);
>  	nobodyuid = pw->pw_uid;
> @@ -328,8 +330,6 @@ main(int argc, char **argv)
>  	if (nfs4_init_name_mapping(conf_path))
>  		errx(1, "Unable to create name to user id mappings.");
>  
> -	daemon_init(fg);
> -
>  	event_init();
>  
>  	if (verbose > 0)
> 
