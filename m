Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E113DC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 15:20:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B94C72083B
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 15:20:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727902AbfBUPU2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 10:20:28 -0500
Received: from fieldses.org ([173.255.197.46]:51202 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725866AbfBUPU1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 10:20:27 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 02FAB1E29; Thu, 21 Feb 2019 10:20:27 -0500 (EST)
Date:   Thu, 21 Feb 2019 10:20:26 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     James Pearson <jcpearson@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: nfsd thread limit and UDP ?
Message-ID: <20190221152026.GB23154@fieldses.org>
References: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
 <20190221041820.GA4625@fieldses.org>
 <CAK3fRr-y3YjX-8hMtutvpy=MQCyqH8YmRBwxyGJ4HmJQwsLyGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK3fRr-y3YjX-8hMtutvpy=MQCyqH8YmRBwxyGJ4HmJQwsLyGw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 21, 2019 at 12:35:46PM +0000, James Pearson wrote:
> On Thu, 21 Feb 2019 at 04:18, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Wed, Feb 20, 2019 at 11:28:53AM +0000, James Pearson wrote:
> > > On a very busy NFSv3 server (running CentOS 6), we recently upped the
> > > nfsd thread count to 1024 - but this caused client mount requests over
> > > UDP to fail.
> > >
> > > We configure all our clients to use TCP for NFS mounts, but the
> > > automounter (automountd) on MacOS (up to version MacOS 10.12) seeds a
> > > 'null call' to the NFS server over UDP before attempting the mount -
> > > but the server appears to ignore any UDP requests - and the automount
> > > fails
> >
> > By the way, you might also just turn off UDP.  (Start run rpc.nfsd with
> > the -U option.)  Hopefully MacOS can handle that case.
> 
> We tried that - but when we restarted nfs, some existing mounts hung
> (not sure why, as we should be just using TCP everywhere) ... although
> when tested on a test server, the MacOS automounter worked fine

It's probably not a good idea to turn off UDP while there are existing
mounts, even if the mounts are supposedly TCP.  At a guess, maybe some
one of the sideband protocols (NLM or NSM) is using UDP and that's
causing problems.

> I tried your patch - it doesn't apply 'as is' on a CentOS 6 kernel -
> but with a bit of manual hacking, I can get it to fit

Whoops, I missed at first that you were on an older kernel.

> However, the net/sunrpc/svcsock.c in these kernels has an extra call
> to svc_sock_setbufsize() :
> 
>         /* Initialize the socket */
>         if (sock->type == SOCK_DGRAM)
>                 svc_udp_init(svsk, serv);
>         else {
>                 /* initialise setting must have enough space to
>                  * receive and respond to one request.
>                  */
>                 svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
>                                         4 * serv->sv_max_mesg);
>                 svc_tcp_init(svsk, serv);
>         }
> 
> I tried replacing that svc_sock_setbufsize() with:
> 
>                 svc_sock_setbufsize(svsk, 4);
> 
> but that just caused the whole machine to lock up shortly after
> sunrpc.ko was loaded ...

Looks like it's trying to dereference svsk->xpt_server before
svc_tcp_init() has initialized it.

> However, things seem to work fine if I call a copy of the original
> svc_sock_setbufsize() at that point in the code with the original args
> ...
> 
> i.e. mounts over UDP (and MacOS automounts) now work with nfsd threads
> over 1017 (I tried 2048 ... and it worked)

OK, I think that's evidence enough that this overflow was the problem
you were hitting, so I'll send that patch upstream.

> Incidentally, I came across an old thread on this list that appears to
> be related to this issue (well, it mentions a 1020 thread limit and
> buffer size wraps in svc_sock_setbufsize() ???) :
> 
>  https://www.spinics.net/lists/linux-nfs/msg34927.html
> 
> ... but I'm not sure what the result of that was (nor if it is
> actually related to the issue here) ?

Yeah, see https://www.spinics.net/lists/linux-nfs/msg34932.html.  So, I
knew about this problem and even made a patch before and then somehow
dropped it.  I'm not sure how that happened.  Anyway, I have it queued
up for 5.1 now, so that shouldn't happen again.

--b.
