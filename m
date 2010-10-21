Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab0JUAox (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 20:44:53 -0400
Date: Wed, 20 Oct 2010 20:45:32 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Cc: chuck.lever@oracle.com, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3
 mounts.
Message-ID: <20101020204532.2019eb93@corrin.poochiereds.net>
In-Reply-To: <20101021074028.44bca336@notabene>
References: <20101020181701.232dbeea@notabene>
	<20101020135525.22977d8d@tlielax.poochiereds.net>
	<20101020151657.42bc53f7@tlielax.poochiereds.net>
	<20101021074028.44bca336@notabene>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 21 Oct 2010 07:40:28 +1100
Neil Brown <neilb@suse.de> wrote:

> > 
> > Then what happens is that xs_tcp_send_request gets called again to try
> > to resend the packet. In the EHOSTUNREACH case, that returns
> > EHOSTUNREACH which eventually causes an rpc_exit with that error. In
> > the ENETUNREACH case that returns EPIPE, which makes the state machine
> > move next to call_bind and the whole thing starts over again.
> 
> This confuses me.  Why would  xs_tcp_send_request (aka ->send_request) get
> called before the connect has succeeded?  Can you make sense of that?
> 

It confuses me too. I suspect that this may actually be a bug...

So EINPROGRESS makes the connect_worker task clear the connecting bit
and return. Eventually, the EHOSTUNREACH error is reported to
xs_error_report. That function does this:

        xprt_wake_pending_tasks(xprt, -EAGAIN);

The task that was waiting on the connect_worker is then woken up.
call_connect_status does this:

        if (status >= 0 || status == -EAGAIN) {
                clnt->cl_stats->netreconn++;
                task->tk_action = call_transmit;
                return;
        }

...and we end up in call_transmit without the socket being connected.

So I understand how this happened, but I don't really understand the
design of the connect mechanism well enough to know whether this is
by design or not.

-- 
Jeff Layton <jlayton@redhat.com>
