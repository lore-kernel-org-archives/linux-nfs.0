Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E956C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 19:56:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5DE702084E
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 19:56:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DE702084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726242AbeLLT4Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 14:56:24 -0500
Received: from mail-qt1-f195.google.com ([209.85.160.195]:44686 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726248AbeLLT4Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 14:56:24 -0500
Received: by mail-qt1-f195.google.com with SMTP id n32so21898253qte.11
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 11:56:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=qp/KFoZelgkLWX8OrYpNSNU3ccP/RA7sbNwsNX01zx4=;
        b=SCvEnp7ESJOajRCHAo/adcy7U8WVDO+6+IdZjjsR74vbWsuZJn8JVQNAaNLOH8herS
         3AQLMuZLqP+mpWsMKg2Hs+6T7tDFhwi39vqTy1oQxGYL7Z+KVFR3yv5ZbW8pkxamvT6T
         Uu4TRMVDeZ9BdhfTBQLiLsKyVfUxJUUx/M800q2PEARoewrRwP2e8QrFUm3PdfEYjXdl
         T9cCVLEUbqbfjoM+JPG+fqU6XS+7XF9v0DbawXyKnkwOBW+2OFESOLB4Aj//7ZqvzlKN
         krzzPdeXhbJ9ZYE8IW1HvXvrVTL+2ECbRUPMzOfCS+UYCbHWWqmDvOzogWv47cwPZZWe
         1J3w==
X-Gm-Message-State: AA+aEWbLF8jcff6gPHmY77u2R3HLugzRjeQ/wix2OySOAek8rsHzc9fk
        9Fd2AOd9K8lf49fVtDMR/LkrBw==
X-Google-Smtp-Source: AFSGD/XxdwOojN4re0d+tYhS2eiddNeYy2x0rkqCq+PA5GHjT1rAvzTB3on2++RD6us2uRgUaAF6zQ==
X-Received: by 2002:ac8:75cc:: with SMTP id z12mr20674314qtq.249.1544644582849;
        Wed, 12 Dec 2018 11:56:22 -0800 (PST)
Received: from dhcp-12-212-173.gsslab.rdu.redhat.com (nat-pool-rdu-t.redhat.com. [66.187.233.202])
        by smtp.gmail.com with ESMTPSA id q70sm13362556qkq.10.2018.12.12.11.56.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 11:56:22 -0800 (PST)
Message-ID: <1544644581.3750.4.camel@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Wed, 12 Dec 2018 14:56:21 -0500
In-Reply-To: <99a88b32d140228d5382eb176d0f19df27483654.camel@hammerspace.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
         <20181212135157.4489-2-dwysocha@redhat.com>
         <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
         <1544636846.3750.2.camel@redhat.com>
         <99a88b32d140228d5382eb176d0f19df27483654.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-14.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2018-12-12 at 18:02 +0000, Trond Myklebust wrote:
> On Wed, 2018-12-12 at 12:47 -0500, Dave Wysochanski wrote:
> > On Wed, 2018-12-12 at 16:56 +0000, Trond Myklebust wrote:
> > > On Wed, 2018-12-12 at 08:51 -0500, Dave Wysochanski wrote:
> > > > Commit 9b30889c548a changed the handling of TCP_CLOSE inside
> > > > xs_tcp_state_change.  Prior to this change, the XPRT_CONNECTED
> > > > bit
> > > > was cleared unconditionally inside xprt_disconnect_done,
> > > > similar
> > > > to the handling of TCP_CLOSE_WAIT.  After the change the
> > > > clearing
> > > > of XPRT_CONNECTED depends on successfully queueing a work based
> > > > xprt_autoclose which depends on XPRT_LOCKED and may not happen.
> > > > This is significant in the case of an unexpected RST from the
> > > > server, as the client will only see xs_tcp_state_change called
> > > > with
> > > > sk_state == TCP_CLOSE.  Restore the unconditional clear_bit on
> > > > XPRT_CONNECTED while handling TCP_CLOSE and make it consistent
> > > > with handling TCP_CLOSE_WAIT.
> > > > 
> > > > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > > > ---
> > > >  net/sunrpc/xprtsock.c | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > > 
> > > > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > > > index 8a5e823e0b33..b9789036051d 100644
> > > > --- a/net/sunrpc/xprtsock.c
> > > > +++ b/net/sunrpc/xprtsock.c
> > > > @@ -1492,6 +1492,7 @@ static void xs_tcp_state_change(struct
> > > > sock
> > > > *sk)
> > > >  		if (sk->sk_err)
> > > >  			xprt_wake_pending_tasks(xprt, -sk-
> > > > > sk_err);
> > > > 
> > > >  		/* Trigger the socket release */
> > > > +		clear_bit(XPRT_CONNECTED, &xprt->state);
> > > >  		xs_tcp_force_close(xprt);
> > > >  	}
> > > >   out:
> > > 
> > > Hi Dave,
> > > 
> > > This isn't needed for 4.20 or newer because call_transmit() will
> > > now
> > > always call xprt_end_transmit(). I suggest that a stable fix do
> > > something similar (perhaps conditional on the error returned by
> > > xprt_transmit()?).
> > > 
> > 
> > Can you explain the handling in xs_tcp_state_change - why
> > XPRT_CONNECTED would need to remain set longer in the case of
> > handling
> > TCP_CLOSE case rather than TCP_CLOSE_WAIT?  It seems like if we get
> > an
> > RST we'll go directly to TCP_CLOSE and why would the XPRT_CONNECTED
> > bit
> > getting cleared need to be delayed in that case?
> > 
> > I will look into the approach you mention though at the moment I do
> > not
> > see how it helps because the underlying issue seems to be clearing
> > of
> > the XPRT_CONNECTED bit.
> > 
> 
> See xprt_clear_locked(). Dropping the XPRT_LOCK will automatically
> trigger autoclose if  XPRT_CLOSE_WAIT is set, regardless of whether
> or
> not there are other tasks waiting for the lock.
> 
> 

Ok thanks for pointing me in that direction I will investigate.

I am actually seeing a hang now with the reproducer on 4.20-rc6 but
it's not CPU spinning.  Investigating as it was not easy to reproduce
but there must still be a race somewhere.


