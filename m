From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] lockd
Date: Mon, 04 Oct 2004 19:50:31 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1096912231.22446.60.camel@lade.trondhjem.org>
References: <41617958.2020406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268372AbUJDRwi@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41617958.2020406@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

P=E5 m=E5 , 04/10/2004 klokka 18:24, skreiv Steve Dickson:

> Hey Neil,

Hey! This is the client side NLM code... 8-)

>  	clear_thread_flag(TIF_SIGPENDING);
> -	interruptible_sleep_on_timeout(&lockd_exit, HZ);
> -	if (nlmsvc_pid) {
> +	set_current_state(TASK_UNINTERRUPTIBLE);

Nope. Those clearly are not the same.

Note that you probably also want to move the call to
set_current_state(TASK_INTERRUPTIBLE) inside the loop. In that case you
can also remove the call to set_current_state(TASK_RUNNING) ('cos
schedule_timeout() will do that for you).

Also, why aren't you using the more standard DECLARE_WAITQUEUE(__wait)?

Cheers,
  Trond
