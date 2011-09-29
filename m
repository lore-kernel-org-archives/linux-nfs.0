Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:42396 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab1I2E2E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2011 00:28:04 -0400
In-Reply-To: <1317210761-11518-3-git-send-email-jlayton@redhat.com>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
	<1317210761-11518-3-git-send-email-jlayton@redhat.com>
Date: Wed, 28 Sep 2011 23:28:02 -0500
Message-ID: <CAH2r5mtBwUkTXLQeXzvTC6oAcz1i9jzPGfiE7XTzDTw12A6C_Q@mail.gmail.com>
Subject: Re: [PATCH 2/4] cifs, freezer: add wait_event_freezekillable and have
 cifs use it
From: Steve French <smfrench@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, pavel@ucw.cz, rjw@sisk.pl,
        linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@calva.com,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The general idea of the patch seems like a good idea to
me.  Assuming testing feedback was good from the problem
reporters, what tree would you want it merged from?

On Wed, Sep 28, 2011 at 6:52 AM, Jeff Layton <jlayton@redhat.com> wrote:
> CIFS currently uses wait_event_killable to put tasks to sleep while
> they await replies from the server. That function though does not
> allow the freezer to run. In many cases, the network interface may
> be going down anyway, in which case the reply will never come. The
> client then ends up blocking the computer from suspending.
>
> Fix this by adding a new wait_event_freezable variant --
> wait_event_freezekillable. The idea is to combine the behavior of
> wait_event_killable and wait_event_freezable -- put the task to
> sleep and only allow it to be awoken by fatal signals, but also
> allow the freezer to do its job.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/cifs/transport.c     |    3 ++-
>  include/linux/freezer.h |   19 +++++++++++++++++--
>  2 files changed, 19 insertions(+), 3 deletions(-)
>
> diff --git a/fs/cifs/transport.c b/fs/cifs/transport.c
> index 10ca6b2..791bc4f 100644
> --- a/fs/cifs/transport.c
> +++ b/fs/cifs/transport.c
> @@ -26,6 +26,7 @@
>  #include <linux/wait.h>
>  #include <linux/net.h>
>  #include <linux/delay.h>
> +#include <linux/freezer.h>
>  #include <asm/uaccess.h>
>  #include <asm/processor.h>
>  #include <linux/mempool.h>
> @@ -324,7 +325,7 @@ wait_for_response(struct TCP_Server_Info *server, struct mid_q_entry *midQ)
>  {
>        int error;
>
> -       error = wait_event_killable(server->response_q,
> +       error = wait_event_freezekillable(server->response_q,
>                                    midQ->midState != MID_REQUEST_SUBMITTED);
>        if (error < 0)
>                return -ERESTARTSYS;
> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> index 1effc8b..3672f73 100644
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -134,10 +134,25 @@ static inline void set_freezable_with_signal(void)
>  }
>
>  /*
> - * Freezer-friendly wrappers around wait_event_interruptible() and
> - * wait_event_interruptible_timeout(), originally defined in <linux/wait.h>
> + * Freezer-friendly wrappers around wait_event_interruptible(),
> + * wait_event_killable() and wait_event_interruptible_timeout(), originally
> + * defined in <linux/wait.h>
>  */
>
> +#define wait_event_freezekillable(wq, condition)                       \
> +({                                                                     \
> +       int __retval;                                                   \
> +       do {                                                            \
> +               __retval = wait_event_killable(wq,                      \
> +                               (condition) || freezing(current));      \
> +               if (__retval && !freezing(current))                     \
> +                       break;                                          \
> +               else if (!(condition))                                  \
> +                       __retval = -ERESTARTSYS;                        \
> +       } while (try_to_freeze());                                      \
> +       __retval;                                                       \
> +})
> +
>  #define wait_event_freezable(wq, condition)                            \
>  ({                                                                     \
>        int __retval;                                                   \
> --
> 1.7.6.2
>
>



-- 
Thanks,

Steve
