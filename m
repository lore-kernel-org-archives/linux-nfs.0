Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:24243 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755207AbcEEPfb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 11:35:31 -0400
From: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] gssd: move read of upcall into main thread
Date: Thu, 5 May 2016 15:35:23 +0000
Message-ID: <A0B61D59-F17E-4FE4-8A51-537AA7939939@netapp.com>
References: <1462286792-8889-1-git-send-email-kolga@netapp.com>
 <1462286792-8889-2-git-send-email-kolga@netapp.com>
 <50edf6a8-4d4c-07d5-af0a-363ac66dbfa5@RedHat.com>
 <AD00DA1B-EBAD-4DD8-B50F-F9378FBA1822@netapp.com>
 <574d004f-4b42-d4aa-60f6-607ffae6dd1b@RedHat.com>
In-Reply-To: <574d004f-4b42-d4aa-60f6-607ffae6dd1b@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 5, 2016, at 10:17 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> Hello,
> 
> On 05/04/2016 10:15 AM, Kornievskaia, Olga wrote:
>> I’m having a hard time picturing what you have in mind. I don’t see how you can allocate, 
>> populate and free in one routine. The logic is we allocate memory, then read the upcall 
>> and only then we create the thread. If either upcall or creation of the thread 
>> fails we need to free the allocated memory.
> Something like this:
> 
> gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void *data)
> {
>        struct clnt_info *clp = data;
> -       pthread_t th;
> -       int ret;
> +       struct clnt_upcall_info *info;
> 
> -       ret = pthread_create(&th, NULL, (void *)handle_gssd_upcall,
> -                               (void *)clp);
> -       if (ret != 0) {
> -               printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
> -                        ret, strerror(errno));
> +       info = alloc_upcall_info(clp);
> +       if (info == NULL)
> +               return;
> +
> +       info->lbuflen = read(clp->gssd_fd, info->lbuf, sizeof(info->lbuf));
> +       if (info->lbuflen <= 0 || info->lbuf[info->lbuflen-1] != '\n') {
> +               printerr(0, "WARNING: %s: failed reading request\n", __func__);
> +               free(info);
>                return;
>        }
> -       wait_for_child_and_detach(th);
> +       info->lbuf[info->lbuflen-1] = 0;
> +
> +       start_upcall_thread(handle_gssd_upcall, info);
> +
> +       free(info);
> +       return;

Gotcha! Sounds good! You can make the modifications. Or just in case since you are traveling, I’ll just send another patch. Please also add any other lines like Modified-by or Signed-off-by that are need.

> }
> 
> static void
> gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
> {
>        struct clnt_info *clp = data;
> -       pthread_t th;
> -       int ret;
> +       struct clnt_upcall_info *info;
> 
> -       ret = pthread_create(&th, NULL, (void *)handle_krb5_upcall,
> -                               (void *)clp);
> -       if (ret != 0) {
> -               printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
> -                        ret, strerror(errno));
> +       info = alloc_upcall_info(clp);
> +       if (info == NULL)
> +               return;
> +
> +       if (read(clp->krb5_fd, &info->uid,
> +                       sizeof(info->uid)) < (ssize_t)sizeof(info->uid)) {
> +               printerr(0, "WARNING: %s: failed reading uid from krb5 "
> +                        "upcall pipe: %s\n", __func__, strerror(errno));
> +               free(info);
>                return;
>        }
> -       wait_for_child_and_detach(th);
> +
> +       start_upcall_thread(handle_krb5_upcall, info);
> +
> +       free(info);
> +       return;
> }
> 
> Then utils/gssd/gssd_proc.c looks something like this:
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index afaaf9e..f1bd571 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -79,7 +79,6 @@
> #include "nfsrpc.h"
> #include "nfslib.h"
> #include "gss_names.h"
> -#include "misc.h"
> 
> /* Encryption types supported by the kernel rpcsec_gss code */
> int num_krb5_enctypes = 0;
> @@ -708,45 +707,21 @@ out_return_error:
>        goto out;
> }
> 
> -/* signal to the parent thread that we have read from the file descriptor.
> - * it should allow the parent to proceed to poll on the descriptor for
> - * the next upcall from the kernel.
> - */
> -static inline void
> -signal_parent_event_consumed(void)
> -{
> -       pthread_mutex_lock(&pmutex);
> -       thread_started = true;
> -       pthread_cond_signal(&pcond);
> -       pthread_mutex_unlock(&pmutex);
> -}
> -
> void
> -handle_krb5_upcall(struct clnt_info *clp)
> +handle_krb5_upcall(struct clnt_upcall_info *info)
> {
> -       uid_t                   uid;
> -       int                     status;
> -
> -       status = read(clp->krb5_fd, &uid, sizeof(uid)) < (ssize_t)sizeof(uid);
> -       signal_parent_event_consumed();
> -
> -       if (status) {
> -               printerr(0, "WARNING: failed reading uid from krb5 "
> -                           "upcall pipe: %s\n", strerror(errno));
> -               return;
> -       }
> +       struct clnt_info *clp = info->clp;
> 
> -       printerr(2, "\n%s: uid %d (%s)\n", __func__, uid, clp->relpath);
> +       printerr(2, "\n%s: uid %d (%s)\n", __func__, info->uid, clp->relpath);
> 
> -       process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
> +       process_krb5_upcall(clp, info->uid, clp->krb5_fd, NULL, NULL);
> }
> 
> void
> -handle_gssd_upcall(struct clnt_info *clp)
> +handle_gssd_upcall(struct clnt_upcall_info *info)
> {
> +       struct clnt_info        *clp = info->clp;
>        uid_t                   uid;
> -       char                    lbuf[RPC_CHAN_BUF_SIZE];
> -       int                     lbuflen = 0;
>        char                    *p;
>        char                    *mech = NULL;
>        char                    *uidstr = NULL;
> @@ -754,19 +729,9 @@ handle_gssd_upcall(struct clnt_info *clp)
>        char                    *service = NULL;
>        char                    *enctypes = NULL;
> 
> -       lbuflen = read(clp->gssd_fd, lbuf, sizeof(lbuf));
> -       signal_parent_event_consumed();
> -
> -       if (lbuflen <= 0 || lbuf[lbuflen-1] != '\n') {
> -               printerr(0, "WARNING: handle_gssd_upcall: "
> -                           "failed reading request\n");
> -               return;
> -       }
> -       lbuf[lbuflen-1] = 0;
> -
> -       printerr(2, "\n%s: '%s' (%s)\n", __func__, lbuf, clp->relpath);
> +       printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
> 
> -       for (p = strtok(lbuf, " "); p; p = strtok(NULL, " ")) {
> +       for (p = strtok(info->lbuf, " "); p; p = strtok(NULL, " ")) {
>                if (!strncmp(p, "mech=", strlen("mech=")))
>                        mech = p + strlen("mech=");
>                else if (!strncmp(p, "uid=", strlen("uid=")))
> @@ -782,7 +747,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>        if (!mech || strlen(mech) < 1) {
>                printerr(0, "WARNING: handle_gssd_upcall: "
>                            "failed to find gss mechanism name "
> -                           "in upcall string '%s'\n", lbuf);
> +                           "in upcall string '%s'\n", info->lbuf);
>                return;
>        }
> 
> @@ -795,7 +760,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>        if (!uidstr) {
>                printerr(0, "WARNING: handle_gssd_upcall: "
>                            "failed to find uid "
> -                           "in upcall string '%s'\n", lbuf);
> +                           "in upcall string '%s'\n", info->lbuf);
>                return;
>        }
> 
> @@ -808,7 +773,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>        if (target && strlen(target) < 1) {
>                printerr(0, "WARNING: handle_gssd_upcall: "
>                         "failed to parse target name "
> -                        "in upcall string '%s'\n", lbuf);
> +                        "in upcall string '%s'\n", info->lbuf);
>                return;
>        }
> 
> @@ -823,7 +788,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>        if (service && strlen(service) < 1) {
>                printerr(0, "WARNING: handle_gssd_upcall: "
>                         "failed to parse service type "
> -                        "in upcall string '%s'\n", lbuf);
> +                        "in upcall string '%s'\n", info->lbuf);
>                return;
>        }
> 
> @@ -835,5 +800,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>                                 "received unknown gss mech '%s'\n", mech);
>                do_error_downcall(clp->gssd_fd, uid, -EACCES);
>        }
> +
> +       return;
> }
> 
> steved.

