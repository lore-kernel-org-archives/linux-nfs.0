Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:62441 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaIZBXg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 21:23:36 -0400
Received: by mail-ig0-f171.google.com with SMTP id hn15so9509130igb.10
        for <linux-nfs@vger.kernel.org>; Thu, 25 Sep 2014 18:23:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140926111005.3124f859@notabene.brown>
References: <1411613479-8803-1-git-send-email-trond.myklebust@primarydata.com>
	<20140926111005.3124f859@notabene.brown>
Date: Thu, 25 Sep 2014 21:23:35 -0400
Message-ID: <CAHQdGtRrpRxDi5FFjNhvptVnh+nqEyAREQA_6eSoExoW9_CsfA@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2014 at 9:10 PM, NeilBrown <neilb@suse.de> wrote:
> On Wed, 24 Sep 2014 22:51:19 -0400 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>
>> The flag RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT was intended introduced in
>> order to allow NFSv4 clients to disable resend timeouts. Since those
>> cause the RPC layer to break the connection, they mess up the duplicate
>> reply caches that remain indexed on the port number in NFSv4..
>>
>> This patch includes the code that was missing in the original to
>> set the appropriate flag in struct rpc_clnt, when the caller of
>> rpc_create() sets RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT.
>>
>> Fixes: 8a19a0b6cb2e (SUNRPC: Add RPC task and client level options to...)
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/clnt.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 488ddeed9363..841565450354 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -461,6 +461,8 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
>>
>>       if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
>>               clnt->cl_autobind = 1;
>> +     if (args->flags & RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT)
>> +             clnt->cl_noretranstimeo = 1;
>>       if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
>>               clnt->cl_discrtry = 1;
>>       if (!(args->flags & RPC_CLNT_CREATE_QUIET))
>
> Hi Trond,
>  do this relate to my observation in
>     Subject: Re: NFS auto-reconnect tuning
>
>  that NFSv4 closes a connections after the first timeout?
>  This patch seems to be a step towards changing that behaviour, though it
>  doesn't succeed.
>
> You would need
>
> @@ -580,6 +582,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
>         new->cl_autobind = 0;
>         new->cl_softrtry = clnt->cl_softrtry;
>         new->cl_discrtry = clnt->cl_discrtry;
> +       new->cl_noretranstimeo = clnt->cl_noretranstimeo;

D'oh! Yes, of course that is correct.

>         new->cl_chatty = clnt->cl_chatty;
>         return new;
>
> as well.
>
> What do you think of having the client close the connection more quickly when
> there is a timeout?  There does seem to be a case for closing sooner than 30
> minutes...
>
> I must admit I'm a bit confused by these flags so I might be missing
> something important.

Actually, the whole idea is to stop the client from disconnecting when
it doesn't need to. Disconnect == very bad, since it typically breaks
the duplicate reply cache semantics and it can interrupt RPC calls
that may be in progress on the server.
Furthermore, the NFSv4 server is supposed to guarantee to us that it
will always reply to an RPC call (provided that the connection stays
up), so the whole business of disconnecting was misguided in the first
place. The only thing we need is to detect accidental disconnections
(i.e. network partitions), and the way to do that is to use TCP
keepalive. The new code will therefore interpret the NFSv4 'timeo'
mount parameter as the TCP keepalive timeout rather than as a
retransmission timeout.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
