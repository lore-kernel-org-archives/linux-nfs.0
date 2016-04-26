Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33800 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbcDZQvO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 12:51:14 -0400
Received: by mail-qk0-f177.google.com with SMTP id r184so7921590qkc.1
        for <linux-nfs@vger.kernel.org>; Tue, 26 Apr 2016 09:51:13 -0700 (PDT)
Message-ID: <1461689470.4200.7.camel@poochiereds.net>
Subject: Re: [PATCH v4 2/3] gssd: using syscalls directly to change thread's
 identity
From: Jeff Layton <jlayton@poochiereds.net>
To: Olga Kornievskaia <kolga@netapp.com>, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Apr 2016 12:51:10 -0400
In-Reply-To: <1461677655-68294-3-git-send-email-kolga@netapp.com>
References: <1461677655-68294-1-git-send-email-kolga@netapp.com>
	 <1461677655-68294-3-git-send-email-kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-04-26 at 09:34 -0400, Olga Kornievskaia wrote:
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
> index e2e95dc..39c4b17 100644
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
> +	if (syscall(SYS_setresgid, pw->pw_gid, -1, -1) != 0) {
>  		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
>  		return errno;
>  	}
> @@ -466,7 +472,7 @@ change_identity(uid_t uid)
>  	 * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
>  	 * other processes running with this uid.
>  	 */
> -	if (setresuid(uid, uid, -1) != 0) {
> +	if (syscall(SYS_setresuid, uid, -1, -1) != 0) {
>  		printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
>  				uid);
>  		return errno;

Note that the old code set both real and effective uid/gid. Here you're
changing it to just set the real uid. Is that change deliberate? I
think you probably want to set the euid/egid as well.

-- 
Jeff Layton <jlayton@poochiereds.net>
