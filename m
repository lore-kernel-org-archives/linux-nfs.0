Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C4F8C67839
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 13:48:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2654220656
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 13:48:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729656AbeLNNsy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 08:48:54 -0500
Received: from mail-qk1-f196.google.com ([209.85.222.196]:40488 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726554AbeLNNsy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Dec 2018 08:48:54 -0500
Received: by mail-qk1-f196.google.com with SMTP id y16so3236403qki.7
        for <linux-nfs@vger.kernel.org>; Fri, 14 Dec 2018 05:48:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=FtoKZE0TdIp3kSlhHspORWeBwKZiyg5Vp2gg1eOB62k=;
        b=AFJNts/tjjbTbKTbcCBPYn/ujLWDybKsZBEWxtLXyBalC4o/1wwlvY77pBsT+1aJlX
         OGKZk/43Fd/NYuauVRGHWIbXsoPVhUiAuB8Jv9iQ9XuZqb3elzJ0PjM9+Xy73szeJaRm
         8V8UzvGqzSX0E1pPVpd6P/tmmxMqBZzj1iaHkYEiNvtsq/J7SB3/yednxlYK8wS3+xdy
         DHzCLY3ESUB+m/m/99UUHVrdY9sJxDXTo8xT+3jRPFcMZMbfUJ9J+U06u8lMiPwMeZY0
         AbPrNBTljTANPn9fTxyeltVD0KZi2s2jo930dAZF1q1cooD5QR+yaluV5JnVwYSF6yTL
         dPzw==
X-Gm-Message-State: AA+aEWa2gCNa+v8V1hgLeL1nqJbyBeyetJHOUQJRkwWz1IhODzIraz8H
        TuckxshCvQA3JEJHw6/ziw/40A==
X-Google-Smtp-Source: AFSGD/WgGbcFiGiTXrSajxnBDMtKNcv/HLYy90L4Y5NSCltjWMSVEBxzvvkD+esmGPEV2s24qzxDSQ==
X-Received: by 2002:a37:5bc1:: with SMTP id p184mr2667663qkb.121.1544795332634;
        Fri, 14 Dec 2018 05:48:52 -0800 (PST)
Received: from dwysocha.rdu.csb (75-26-10-140.lightspeed.rlghnc.sbcglobal.net. [75.26.10.140])
        by smtp.gmail.com with ESMTPSA id c77sm4138354qkh.82.2018.12.14.05.48.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 05:48:52 -0800 (PST)
Message-ID: <1544795330.4709.3.camel@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Fri, 14 Dec 2018 08:48:50 -0500
In-Reply-To: <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
         <20181212135157.4489-2-dwysocha@redhat.com>
         <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-14.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2018-12-12 at 16:56 +0000, Trond Myklebust wrote:
> On Wed, 2018-12-12 at 08:51 -0500, Dave Wysochanski wrote:
> > Commit 9b30889c548a changed the handling of TCP_CLOSE inside
> > xs_tcp_state_change.  Prior to this change, the XPRT_CONNECTED bit
> > was cleared unconditionally inside xprt_disconnect_done, similar
> > to the handling of TCP_CLOSE_WAIT.  After the change the clearing
> > of XPRT_CONNECTED depends on successfully queueing a work based
> > xprt_autoclose which depends on XPRT_LOCKED and may not happen.
> > This is significant in the case of an unexpected RST from the
> > server, as the client will only see xs_tcp_state_change called with
> > sk_state == TCP_CLOSE.  Restore the unconditional clear_bit on
> > XPRT_CONNECTED while handling TCP_CLOSE and make it consistent
> > with handling TCP_CLOSE_WAIT.
> > 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> >  net/sunrpc/xprtsock.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 8a5e823e0b33..b9789036051d 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1492,6 +1492,7 @@ static void xs_tcp_state_change(struct sock
> > *sk)
> >  		if (sk->sk_err)
> >  			xprt_wake_pending_tasks(xprt, -sk-
> > >sk_err);
> >  		/* Trigger the socket release */
> > +		clear_bit(XPRT_CONNECTED, &xprt->state);
> >  		xs_tcp_force_close(xprt);
> >  	}
> >   out:
> 
> Hi Dave,
> 
> This isn't needed for 4.20 or newer because call_transmit() will now
> always call xprt_end_transmit(). I suggest that a stable fix do
> something similar (perhaps conditional on the error returned by
> xprt_transmit()?).
> 
> 

It appears the "Special cases" comment inside call_transmit_status()
should be removed now, do you agree?

Also I guess you are not concerned about this issue anymore that
created the comment and the cases?
https://lore.kernel.org/patchwork/patch/165428/

Also for a stable fix, would you prefer handling all of the codes on
lines 39-43 the same and removing that comment, or just EPIPE we are
seeing in the testcase?

After some discussion with Scott we're testing variants on the above
(see below for possible fixes).  Any preferences on option 1 or option
2?

Thanks.




Upstream (4.20-rc6) has a comment but it looks wrong due to code in call_transmit():
   1971 static void
   1972 call_transmit(struct rpc_task *task)
   1973 {
   1974         dprint_status(task);
   1975 
   1976         task->tk_status = 0;
   1977         if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
   1978                 if (!xprt_prepare_transmit(task))
   1979                         return;
   1980                 xprt_transmit(task);
   1981         }
   1982         task->tk_action = call_transmit_status;
   1983         xprt_end_transmit(task);   <--------------------- Always drop the XPRT_LOCK
   1984 }
...
   1989 static void
   1990 call_transmit_status(struct rpc_task *task)
   1991 {
   1992         task->tk_action = call_status;
   1993 
   1994         /*
   1995          * Common case: success.  Force the compiler to put this
   1996          * test first.
   1997          */
   1998         if (task->tk_status == 0) {
   1999                 xprt_request_wait_receive(task);
   2000                 return;
   2001         }
   2002 
   2003         switch (task->tk_status) {
   2004         default:
   2005                 dprint_status(task);
   2006                 break;
   2007         case -EBADMSG:
   2008                 task->tk_status = 0;
   2009                 task->tk_action = call_encode;
   2010                 break;
   2011                 /*
   2012                  * Special cases: if we've been waiting on the  <---- WRONG
   2013                  * socket's write_space() callback, or if the  <----- WRONG
   2014                  * socket just returned a connection error,  <------- WRONG
   2015                  * then hold onto the transport lock.    <----------- WRONG 
   2016                  */
   2017         case -ENOBUFS:
   2018                 rpc_delay(task, HZ>>2);
   2019                 /* fall through */
   2020         case -EBADSLT:
   2021         case -EAGAIN:
   2022                 task->tk_action = call_transmit;
   2023                 task->tk_status = 0;
   2024                 break;
   2025         case -ECONNREFUSED:
   2026         case -EHOSTDOWN:
   2027         case -ENETDOWN:
   2028         case -EHOSTUNREACH:
   2029         case -ENETUNREACH:
   2030         case -EPERM:
   2031                 if (RPC_IS_SOFTCONN(task)) {
   2032                         if (!task->tk_msg.rpc_proc->p_proc)
   2033                                 trace_xprt_ping(task->tk_xprt,
   2034                                                 task->tk_status);
   2035                         rpc_exit(task, task->tk_status);
   2036                         break;
   2037                 }
   2038                 /* fall through */
   2039         case -ECONNRESET:
   2040         case -ECONNABORTED:
   2041         case -EADDRINUSE:
   2042         case -ENOTCONN:
   2043         case -EPIPE:
   2044                 break;
   2045         }
   2046 }



For 4.16 - 4.19 possible fixes


Possible fix #1 - just remove EPIPE and/or all the codes and move these to 'default':


2002 static void
2003 call_transmit_status(struct rpc_task *task)
2004 {
2005         task->tk_action = call_status;
2006 
2007         /*
2008          * Common case: success.  Force the compiler to put this
2009          * test first.
2010          */
2011         if (task->tk_status == 0) {
2012                 xprt_end_transmit(task);
2013                 rpc_task_force_reencode(task);
2014                 return;
2015         }
2016 
2017         switch (task->tk_status) {
2018         case -EAGAIN:
2019         case -ENOBUFS:
2020                 break;
2021         default:
2022                 dprint_status(task);
2023                 xprt_end_transmit(task);
2024                 rpc_task_force_reencode(task);
2025                 break;
2026                 /*
2027                  * Special cases: if we've been waiting on the
2028                  * socket's write_space() callback, or if the
2029                  * socket just returned a connection error,  <----------- WRONG ???
2030                  * then hold onto the transport lock.     <-------------- WRONG ???
2031                  */
2032         case -ECONNREFUSED:
2033         case -EHOSTDOWN:
2034         case -EHOSTUNREACH:
2035         case -ENETUNREACH:
2036         case -EPERM:
2037                 if (RPC_IS_SOFTCONN(task)) {
2038                         xprt_end_transmit(task);
2039                         rpc_exit(task, task->tk_status);
2040                         break;
2041                 }
2042         case -ECONNRESET:  <------- ????
2043         case -ECONNABORTED: <------ ????
2044         case -EADDRINUSE:  <------- ???? 
2045         case -ENOTCONN:   <-------- ???? What about these others ???
2046         case -EPIPE:  <------------------------------ remove this line to fix bug
2047                 rpc_task_force_reencode(task);
2048         }
2049 }



Possible fix #2: make calling xprt_end_transmit() conditional on both EPIPE and xprt_connected()


 	case -EPIPE:
+		if (xprt_connected(task->tk_xprt))
+			xprt_end_transmit(task);
