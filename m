Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33197 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcD1NOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 09:14:32 -0400
Received: by mail-qg0-f51.google.com with SMTP id f92so29447790qgf.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Apr 2016 06:14:31 -0700 (PDT)
Message-ID: <1461849269.15736.9.camel@poochiereds.net>
Subject: Re: [PATCH v5 2/3] gssd: using syscalls directly to change thread's
 identity
From: Jeff Layton <jlayton@poochiereds.net>
To: Olga Kornievskaia <kolga@netapp.com>, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 28 Apr 2016 09:14:29 -0400
In-Reply-To: <1461776287-1427-3-git-send-email-kolga@netapp.com>
References: <1461776287-1427-1-git-send-email-kolga@netapp.com>
	 <1461776287-1427-3-git-send-email-kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-04-27 at 12:58 -0400, Olga Kornievskaia wrote:
> For the threaded version we have to set uid,gid per thread instead
> of per process. glibc setresuid() when called from a thread, it'll
> send a signal to all other threads to synchronize the uid in all
> other threads. To bypass this, we have to call syscall() directly.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> Reviewed-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/gssd_proc.c | 19 +++++++++----------
>  1 file changed, 9 insertions(+), 10 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index e2e95dc..de8dc07 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -69,6 +69,7 @@
>  #include 
>  #include 
>  #include 
> +#include 
>  
>  #include "gssd.h"
>  #include "err_util.h"
> @@ -436,7 +437,7 @@ change_identity(uid_t uid)
>  	struct passwd	*pw;
>  
>  	/* drop list of supplimentary groups first */
> -	if (setgroups(0, NULL) != 0) {
> +	if (syscall(SYS_setgroups, 0, 0) != 0) {
>  		printerr(0, "WARNING: unable to drop supplimentary groups!");
>  		return errno;
>  	}
> @@ -453,20 +454,18 @@ change_identity(uid_t uid)
>  		}
>  	}
>  
> -	/*
> -	 * Switch the GIDs. Note that we leave the saved-set-gid alone in an
> -	 * attempt to prevent attacks via ptrace()
> +	/* Switch the UIDs and GIDs. */
> +	/* For the threaded version we have to set uid,gid per thread instead
> +	 * of per process. glibc setresuid() when called from a thread, it'll
> +	 * send a signal to all other threads to synchronize the uid in all
> +	 * other threads. To bypass this, we have to call syscall() directly.
>  	 */
> -	if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
> +	if (syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid) != 0) {
>  		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
>  		return errno;
>  	}
>  
> -	/*
> -	 * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
> -	 * other processes running with this uid.
> -	 */
> -	if (setresuid(uid, uid, -1) != 0) {
> +	if (syscall(SYS_setresuid, uid, uid, uid) != 0) {
>  		printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
>  				uid);
>  		return errno;

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
