Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 498A8C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 12:13:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 191A62075A
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 12:13:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726043AbfBVMNA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 07:13:00 -0500
Received: from mail-qt1-f193.google.com ([209.85.160.193]:44006 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725926AbfBVMNA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 07:13:00 -0500
Received: by mail-qt1-f193.google.com with SMTP id y4so2129524qtc.10
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 04:12:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ruGOZYW4RZGWSAWSA11jr0aFZHZV+AWmN1lC0pTdvvU=;
        b=PQN+9FBa0WvbjbIU4yncL4JPwjzwRB+Wwwd2KiDt9IkdG6yAs8PnQVczRooWPrIIYa
         RsoqKDJk5QEfuuDWgbOpp0kienotd1y9aFFJwVnWGC9hkre0wErIf+IyI6U+ptYi3JhG
         KlkRtNJL6RnOr0R1jLuPaHGSQQbvRSD9D/rPVDz/ktCA6G+fk/KjggMUQNVmXgiEEuSt
         QPRGbQurp2ApC4YiOxZEkvVJQx0o4ti2Er/B5snLud1676h72Rn25jXCAQN579eEjw2z
         eTRhH1k9lIBpHwdd/z7+luRPkrMQG66CJGKYaGaiVR8UgygT+IvIiM+5tm9AHGXzPxUs
         l2LQ==
X-Gm-Message-State: AHQUAuZZJRlbg4MN3wQktxGIbIp/FbZ7fIVUMumT8aT1VZrM6Ginrj/P
        H5uyCYonRJgF5n6+NOm+L1EBOg==
X-Google-Smtp-Source: AHgI3IYOtY6w37XyPKCX1LoroyeXAEFCacS9BvAMuLhT7EYO8hXIrNxzrHyEaNMUzCzjCmyj0GAFUA==
X-Received: by 2002:ac8:37d5:: with SMTP id e21mr2779696qtc.214.1550837578838;
        Fri, 22 Feb 2019 04:12:58 -0800 (PST)
Received: from dwysocha.rdu.csb (75-26-10-140.lightspeed.rlghnc.sbcglobal.net. [75.26.10.140])
        by smtp.gmail.com with ESMTPSA id j66sm1146533qkj.27.2019.02.22.04.12.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:12:58 -0800 (PST)
Message-ID: <1550837576.6456.3.camel@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Fri, 22 Feb 2019 07:12:56 -0500
In-Reply-To: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-14.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga,

Do you have a reproducer for this?  A number of months ago I did a
significant amount of testing with half-closed connections, after we
had reports of connections stuck in FIN_WAIT2 in some older kernels. 
What I found was with kernels that had the tcp keepalives (commit
7f260e8575bf53b93b77978c1e39f8e67612759c), I could only reproduce a
hang of a few minutes, after which time the tcp keepalive code would
reset the connection.

That said it was a while ago and something subtle may have changed. 
Also I'm not not sure if your header implies an indefinite hang or just
a few minutes.

Thanks.


On Wed, 2019-02-20 at 09:56 -0500, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> When server replies with an ACK to client's FIN/ACK, client ends
> up stuck in a TCP_FIN_WAIT2 state and client's mount hangs.
> Instead, make sure to close and reset client's socket and transport
> when transitioned into that state.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  net/sunrpc/xprtsock.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 618e9c2..812e5e3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1502,6 +1502,7 @@ static void xs_tcp_state_change(struct sock
> *sk)
>  		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>  		smp_mb__after_atomic();
>  		break;
> +	case TCP_FIN_WAIT2:
>  	case TCP_CLOSE_WAIT:
>  		/* The server initiated a shutdown of the socket */
>  		xprt->connect_cookie++;
> @@ -2152,6 +2153,7 @@ static void xs_tcp_shutdown(struct rpc_xprt
> *xprt)
>  		kernel_sock_shutdown(sock, SHUT_RDWR);
>  		trace_rpc_socket_shutdown(xprt, sock);
>  		break;
> +	case TCP_FIN_WAIT2:
>  	case TCP_CLOSE:
>  	case TCP_TIME_WAIT:
>  		xs_reset_transport(transport);
