Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 000E8C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 18:29:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E65C206C2
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 18:29:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729962AbeLNS3h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 13:29:37 -0500
Received: from mx1.redhat.com ([209.132.183.28]:39872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729707AbeLNS3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Dec 2018 13:29:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A9E5EC079C2C;
        Fri, 14 Dec 2018 18:29:36 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 59100608E0;
        Fri, 14 Dec 2018 18:29:36 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id E3E6F20688; Fri, 14 Dec 2018 13:29:35 -0500 (EST)
Date:   Fri, 14 Dec 2018 13:29:35 -0500
From:   Scott Mayhew <smayhew@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
Message-ID: <20181214182935.GI27213@coeurl.usersys.redhat.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
 <20181212135157.4489-2-dwysocha@redhat.com>
 <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 14 Dec 2018 18:29:36 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 12 Dec 2018, Trond Myklebust wrote:

> On Wed, 2018-12-12 at 08:51 -0500, Dave Wysochanski wrote:
> > Commit 9b30889c548a changed the handling of TCP_CLOSE inside
> > xs_tcp_state_change.  Prior to this change, the XPRT_CONNECTED bit
> > was cleared unconditionally inside xprt_disconnect_done, similar
> > to the handling of TCP_CLOSE_WAIT.  After the change the clearing
> > of XPRT_CONNECTED depends on successfully queueing a work based
> > xprt_autoclose which depends on XPRT_LOCKED and may not happen.
> > This is significant in the case of an unexpected RST from the
> > server, as the client will only see xs_tcp_state_change called with
> > sk_state == TCP_CLOSE.  Restore the unconditional clear_bit on
> > XPRT_CONNECTED while handling TCP_CLOSE and make it consistent
> > with handling TCP_CLOSE_WAIT.
> > 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> >  net/sunrpc/xprtsock.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 8a5e823e0b33..b9789036051d 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1492,6 +1492,7 @@ static void xs_tcp_state_change(struct sock
> > *sk)
> >  		if (sk->sk_err)
> >  			xprt_wake_pending_tasks(xprt, -sk->sk_err);
> >  		/* Trigger the socket release */
> > +		clear_bit(XPRT_CONNECTED, &xprt->state);
> >  		xs_tcp_force_close(xprt);
> >  	}
> >   out:
> 
> Hi Dave,
> 
> This isn't needed for 4.20 or newer because call_transmit() will now
> always call xprt_end_transmit().

Dave's script can also produce a hang on 4.20, but for a different
reason... if xs_reset_transport() is called on an xprt that has
XPRT_WRITE_SPACE set, then no further RPC tasks will be able to lock the
transport or connect it.  Clearing XPRT_WRITE_SPACE in
xs_sock_reset_connection_flags() seems to fix that. I don't know if
XPRT_WRITE_SPACE counts as a "connection flag" though.

-Scott

> I suggest that a stable fix do
> something similar (perhaps conditional on the error returned by
> xprt_transmit()?).
> 
> Cheers
>   Trond
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 
