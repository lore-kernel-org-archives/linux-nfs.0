Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B427C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 17:47:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F32022086D
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 17:47:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F32022086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727681AbeLLRra (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 12:47:30 -0500
Received: from mail-qt1-f193.google.com ([209.85.160.193]:44867 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726922AbeLLRra (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 12:47:30 -0500
Received: by mail-qt1-f193.google.com with SMTP id n32so21417028qte.11
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 09:47:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=2h6UbQmW04FmoBPoSg63GvFA3Hr/DDuiaP07S9moaZg=;
        b=cF/NLwEh7AhjZ0IN8qyoLkrozTYiTJjfR5jfNCkODKqn4Mp0T0fKWqgebhdQ5Tr9p/
         qmhJK1SRR7lJHVfNncrJAL2vfYwRrHE7Y49UJnErgVjtvJ6M7HzSNqt3DSrC5Eam2QJg
         CfT/ORhrgOA6WPQfWF+YwGsL4odm2X8lL0sOphIkQJqVKn0b848tS9whrwK2qvBeoIs2
         Fyi6UleW+Ir7IM9b25mq6PhI5lqTzFN3LT4s0GjxLdFpsz5XDUOUi4ggTY5Moe32nA8U
         eQIqM4fQrwQ5WDY+yt1NpHNcTKwrd0k+PEjoDUiTefu0oBWe2pygYzLH4CCzHVCVmafg
         rhlg==
X-Gm-Message-State: AA+aEWb9v8YA+Ngv7VKGe32ePnKVm07yiOlqsdsCStHsS/k4OhIiIBHe
        jCuiRl17eC+ShomfWpphdI5FTA==
X-Google-Smtp-Source: AFSGD/Wo10VNk+dXGfR567mMjYk4k6CdYiLfpHqRdcCy+8iZ846Ga7lvHBwDzYyrFrg93vVrm3R+EA==
X-Received: by 2002:a0c:ac04:: with SMTP id l4mr19759570qvb.4.1544636848709;
        Wed, 12 Dec 2018 09:47:28 -0800 (PST)
Received: from dhcp-12-212-173.gsslab.rdu.redhat.com (nat-pool-rdu-t.redhat.com. [66.187.233.202])
        by smtp.gmail.com with ESMTPSA id 64sm9245667qke.39.2018.12.12.09.47.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 09:47:28 -0800 (PST)
Message-ID: <1544636846.3750.2.camel@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Wed, 12 Dec 2018 12:47:26 -0500
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

Can you explain the handling in xs_tcp_state_change - why
XPRT_CONNECTED would need to remain set longer in the case of handling
TCP_CLOSE case rather than TCP_CLOSE_WAIT?  It seems like if we get an
RST we'll go directly to TCP_CLOSE and why would the XPRT_CONNECTED bit
getting cleared need to be delayed in that case?

I will look into the approach you mention though at the moment I do not
see how it helps because the underlying issue seems to be clearing of
the XPRT_CONNECTED bit.

Thanks.
