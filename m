Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35358 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753816AbcKDMgC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2016 08:36:02 -0400
Message-ID: <1478262960.7065.459.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v2 1/2] net/sock: add an explicit sk argument
 for ip_cmsg_recv_offset()
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Fri, 04 Nov 2016 05:36:00 -0700
In-Reply-To: <1b4e5292a0c15494515423245e8eeb7adf2ebcea.1478254512.git.pabeni@redhat.com>
References: <cover.1478254512.git.pabeni@redhat.com>
         <1b4e5292a0c15494515423245e8eeb7adf2ebcea.1478254512.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-11-04 at 11:28 +0100, Paolo Abeni wrote:
> So that we can use it even after orphaining the skbuff.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
> @Eric, please add your signed off by when you feel comfortable with the patch
> as you basically authored it

> -void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
> -			 int tlen, int offset)
> +void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
> +			 struct sk_buff *skb, int tlen, int offset)
>  {
> -	struct inet_sock *inet = inet_sk(skb->sk);
> +	struct inet_sock *inet = inet_sk(sk);
>  	unsigned int flags = inet->cmsg_flags;

My final version had :

void ip_cmsg_recv_offset(struct msghdr *msg, const struct sock *sk,
                         struct sk_buff *skb, int tlen, int offset)
{
	unsigned int flags = inet_sk(sk)->cmsg_flags;


(Ie not using "struct inet_sock *inet = ...", and a const pointer for
struct sock)

Other than that minor details :

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !


