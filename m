Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33907 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964800AbcDYUXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 16:23:16 -0400
Received: by mail-qk0-f179.google.com with SMTP id r184so67188420qkc.1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2016 13:23:16 -0700 (PDT)
Message-ID: <1461615792.4288.31.camel@poochiereds.net>
Subject: Re: [PATCH v3 2/3] gssd: using syscalls directly to change thread's
 identity
From: Jeff Layton <jlayton@poochiereds.net>
To: Olga Kornievskaia <kolga@netapp.com>, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2016 16:23:12 -0400
In-Reply-To: <1461603513-67523-3-git-send-email-kolga@netapp.com>
References: <1461603513-67523-1-git-send-email-kolga@netapp.com>
	 <1461603513-67523-3-git-send-email-kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-04-25 at 12:58 -0400, Olga Kornievskaia wrote:
> For the threaded version we have to set uid,gid per thread instead
> of per process. glibc setresuid() when called from a thread, it'll
> send a signal to all other threads to synchronize the uid in all
> other threads. To bypass this, we have to call syscall() directly.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> Reviewed-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/gssd_proc.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index e2e95dc..487a4f5 100644
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
> +	if (syscall(SYS_setgroups, 0) != 0) {
>  		printerr(0, "WARNING: unable to drop supplimentary groups!");
>  		return errno;
>  	}
> @@ -457,7 +458,12 @@ change_identity(uid_t uid)
>  	 * Switch the GIDs. Note that we leave the saved-set-gid alone in an
>  	 * attempt to prevent attacks via ptrace()
>  	 */
> -	if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
> +	/* For the threaded version we have to set uid,gid per thread instead
> +	 * of per process. glibc setresuid() when called from a thread, it'll
> +	 * send a signal to all other threads to synchronize the uid in all
> +	 * other threads. To bypass this, we have to call syscall() directly.
> +	 */
> +	if (syscall(SYS_setresgid, pw->pw_gid) != 0) {
>  		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
>  		return errno;
>  	}
> @@ -466,7 +472,7 @@ change_identity(uid_t uid)
>  	 * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
>  	 * other processes running with this uid.
>  	 */
> -	if (setresuid(uid, uid, -1) != 0) {
> +	if (syscall(SYS_setresuid, uid) != 0) {

That looks wrong. setresuid takes 3 arguments:

    SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)

Ditto for setresgid above. syscall is a varargs function, so you really
_must_ pass in the right number of args or you'll end up feeding it
random junk in registers or off the stack. The compiler won't save you
here...
> 		printerr(0, "WARNING: Failed to setuid for user with
uid %u\n",
>  				uid);
>  		return errno;
-- 
Jeff Layton <jlayton@poochiereds.net>
