Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751826AbdBPKWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 05:22:50 -0500
Subject: Re: [PATCH] mount: call setgroups() before setuid()
To: NeilBrown <neilb@suse.com>
References: <877f51wqye.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <9f2dec82-781a-6a85-f593-b6ec67ffe156@RedHat.com>
Date: Thu, 16 Feb 2017 05:22:50 -0500
MIME-Version: 1.0
In-Reply-To: <877f51wqye.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2017 05:56 PM, NeilBrown wrote:
> It is generally wise to call setgroups() (and setgid()) before calling
> setuid() to ensure no unexpected permission leaks happen.
> SUSE's build system checks all binaries for conformance with this
> and generates a warning for mountd.
>
> As we are setting the uid to 0, there is no risk that the group list
> will provide extra permissions, so there is no real risk here.
> But it is nice to silence warnings, and including a setgroups()
> call is probably a good practice to encourage.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed...

steved.

> ---
>  utils/mount/network.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index d1c8fec75174..281e9354a7fa 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -33,6 +33,7 @@
>  #include <errno.h>
>  #include <netdb.h>
>  #include <time.h>
> +#include <grp.h>
>  
>  #include <sys/types.h>
>  #include <sys/socket.h>
> @@ -804,6 +805,7 @@ int start_statd(void)
>  			pid_t pid = fork();
>  			switch (pid) {
>  			case 0: /* child */
> +				setgroups(0, NULL);
>  				setgid(0);
>  				setuid(0);
>  				execle(START_STATD, START_STATD, NULL, envp);

