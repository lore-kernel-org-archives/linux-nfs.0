Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34847 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbcAFRU2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2016 12:20:28 -0500
Received: by mail-oi0-f50.google.com with SMTP id l9so269518800oia.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jan 2016 09:20:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANn89iJOo+L5GO87Qrt2imWNFr-A0Q4QnPksBaC0x58=sfZUqg@mail.gmail.com>
References: <1452098339-3161-1-git-send-email-trond.myklebust@primarydata.com>
	<CANn89iJOo+L5GO87Qrt2imWNFr-A0Q4QnPksBaC0x58=sfZUqg@mail.gmail.com>
Date: Wed, 6 Jan 2016 12:20:27 -0500
Message-ID: <CAHQdGtSUvan-7R0zS99kD7Xi8ogDsZQNNz-EQs5t1QcGq7finw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fixup socket wait for memory
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Eric Dumazet <edumazet@google.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 6, 2016 at 11:49 AM, Eric Dumazet <edumazet@google.com> wrote:
> Hi Trond, sorry for the mess :(

No problem. It did force me to look again at that part of the code; it
turns out most of the stuff we were open coding is now handled in the
socket code itself.

> On Wed, Jan 6, 2016 at 11:38 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> We're seeing hangs in the NFS client code, with loops of the form:
>>
>>
> ...
>
>>  static void xs_write_space(struct sock *sk)
>>  {
>>         struct socket *sock;
>
> It seems you no longer need this @sock variable
>
>> +       struct socket_wq *wq;
>>         struct rpc_xprt *xprt;
>>
>>         if (unlikely(!(sock = sk->sk_socket)))
>
> if (!sk->sk_socket)
>         return;

Fixed... Thanks!

>
> Maybe you don't even need to test sk_socket, but probably better not
> leave it for this fix.

Yes. I'll look again at future cleanups. For now, I just want to get
4.4 working again.

>> @@ -1618,10 +1608,14 @@ static void xs_write_space(struct sock *sk)
>>
>>         if (unlikely(!(xprt = xprt_from_sock(sk))))
>>                 return;
>> -       if (test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->flags) == 0)
>> -               return;
>> +       rcu_read_lock();
>> +       wq = rcu_dereference(sk->sk_wq);
>> +       if (!wq || test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &wq->flags) == 0)
>> +               goto out;
>>
>>         xprt_write_space(xprt);
>> +out:
>> +       rcu_read_unlock();
>>

Thanks for the review!
