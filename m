Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:34606 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbbFLPnp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 11:43:45 -0400
Message-ID: <1434123822.27504.89.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 12 Jun 2015 08:43:42 -0700
In-Reply-To: <CAHQdGtROSzCUWaFobiEPPb2TZwduoARaHQ7viQC=XhjzyXGtrQ@mail.gmail.com>
References: <20150611234929.7b48d314@gandalf.local.home>
	 <CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	 <1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHQdGtROSzCUWaFobiEPPb2TZwduoARaHQ7viQC=XhjzyXGtrQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2015-06-12 at 10:57 -0400, Trond Myklebust wrote:
> On Fri, Jun 12, 2015 at 10:40 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Strange, because the usual way to not have time-wait is to use SO_LINGER
> > with linger=0
> >
> > And apparently xs_tcp_finish_connecting() has this :
> >
> >                 sock_reset_flag(sk, SOCK_LINGER);
> >                 tcp_sk(sk)->linger2 = 0;
> 
> Are you sure? I thought that SO_LINGER is more about controlling how
> the socket behaves w.r.t. waiting for the TCP_CLOSE state to be
> achieved (i.e. about aborting the FIN state negotiation early). I've
> never observed an effect on the TCP time-wait states.

Definitely this is standard way to avoid time-wait states.

Maybe not very well documented. We probably should...

http://stackoverflow.com/questions/3757289/tcp-option-so-linger-zero-when-its-required




> Yes. SO_REUSEADDR has the problem that it requires you bind to
> something other than 0.0.0.0, so it is less appropriate for outgoing
> connections; the RPC code really should not have to worry about
> routing and routability of a particular source address.

OK understood.

Are you trying to reuse same 4-tuple ?



