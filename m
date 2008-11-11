From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH] gssd: unblock DNOTIFY_SIGNAL in case it was blocked.
Date: Mon, 10 Nov 2008 23:13:21 -0500
Message-ID: <4d569c330811102013wc326591if0aee67b9a56e345@mail.gmail.com>
References: <18712.46537.9006.490726@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:18037 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbYKKENW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 23:13:22 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2843850rvb.1
        for <linux-nfs@vger.kernel.org>; Mon, 10 Nov 2008 20:13:21 -0800 (PST)
In-Reply-To: <18712.46537.9006.490726-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,
I inherited the signal stuff, so my understanding probably isn't any
better than yours.  I won't be able to look closer at this until
Wednesday.  Meanwhile, maybe someone else has a better understanding.

K.C.

On Mon, Nov 10, 2008 at 5:29 PM, Neil Brown <neilb@suse.de> wrote:
>
> I have a situation where rpc.gssd appears to not be working.
> Mount attempts which need to communicate with it block.
>
> I've narrowed down the problem to that fact that all realtime signals
> have been blocked.  This means that DNOTIFY_SIGNAL (which is a
> realtime signal) is never delivered, so gssd never rescans the
> rpc_pipe/nfs directory.
>
> I haven't figured out why the signals are blocked yet, but having
> rpc.gssd fail mysteriously in that situation isn't pleasant.
>
> So I wonder what people think of the following patch.  It simply
> unblocks the signal.  Alternately we can check if it is blocked and
> warn - I'm not really sure of the significance of blocking all these
> signals.  Maybe it's wrong to just unblock them.
>
>
> As an aside, maybe we could change gssd_run to use "ppoll" rather than
> "poll".  Then it would not have to wake up every 500msec to see if it
> missed a signal. We would probably have to check kernel version was at
> least 2.6.16....
>
> NeilBrown
>
>
>
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index 84f04e9..b9f3a06 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -99,6 +99,7 @@ gssd_run()
>        int                     ret;
>        struct sigaction        dn_act;
>        int                     fd;
> +       sigset_t                set;
>
>        /* Taken from linux/Documentation/dnotify.txt: */
>        dn_act.sa_sigaction = dir_notify_handler;
> @@ -106,6 +107,11 @@ gssd_run()
>        dn_act.sa_flags = SA_SIGINFO;
>        sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
>
> +       /* just in case the signal is blocked... */
> +       sigemptyset(&set);
> +       sigaddset(&set, DNOTIFY_SIGNAL);
> +       sigprocmask(SIG_UNBLOCK, &set, NULL);
> +
>        if ((fd = open(pipefs_nfsdir, O_RDONLY)) == -1) {
>                printerr(0, "ERROR: failed to open %s: %s\n",
>                         pipefs_nfsdir, strerror(errno));
>
>
