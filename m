Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:46694 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbeEVT2y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 15:28:54 -0400
Received: by mail-ua0-f195.google.com with SMTP id e8-v6so13090152uam.13
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 12:28:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d9d84d1b2cdb6054aba1ed5124f4d632355dec0b.camel@hammerspace.com>
References: <20180522184048.21586-1-kolga@netapp.com> <d9d84d1b2cdb6054aba1ed5124f4d632355dec0b.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 22 May 2018 15:28:52 -0400
Message-ID: <CAN-5tyEEVqnQgNJq_pbaujsVBeVQ0y0AwNgP=cJxA9aj2=o_9w@mail.gmail.com>
Subject: Re: [PATCH 1/1] [SUNRPC] make sure to clone timeout values
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "kolga@netapp.com" <kolga@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 3:03 PM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
> On Tue, 2018-05-22 at 14:40 -0400, Olga Kornievskaia wrote:
>> From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
>>
>> For pNFS, the operations to DS currently timeout in 10s. According
>> to the spec, the client must not be re-trying an NFSv4.1 operation
>> unless the connection was broken.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  net/sunrpc/clnt.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 6e432ec..97517eb 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -668,6 +668,7 @@ struct rpc_clnt *
>>               .prognumber     = clnt->cl_prog,
>>               .version        = clnt->cl_vers,
>>               .authflavor     = flavor,
>> +             .timeout        = clnt->cl_timeout,
>>       };
>>       return __rpc_clone_client(&args, clnt);
>>  }
>
> What does this patch have to do with pNFS? That's the generic RPC
> client cloning API you are changing.
>
> The pNFS/files timeouts are intended to be set using the
> dataserver_retrans and dataserver_timeo module parameters described at
> the bottom of fs/nfs/filelayout/filelayoutdev.c

Ok so perhaps the code needs to re-written so that it allows for the
DS to get an rpc client with its timeouts set. Which currently doesn't
happen.
