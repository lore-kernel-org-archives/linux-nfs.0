Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:45123 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833AbbBIShY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 13:37:24 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 84C5A28075D
	for <linux-nfs@vger.kernel.org>; Mon,  9 Feb 2015 19:37:22 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 766C44501
	for <linux-nfs@vger.kernel.org>; Mon,  9 Feb 2015 19:37:21 +0100 (MET)
Date: Mon, 9 Feb 2015 19:37:20 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1898050091.1249503.1423507040932.JavaMail.zimbra@desy.de>
In-Reply-To: <CAHQdGtSGS5oJGbjUGBiQ=J6yvx=uQOPzegt2iL-yPVMp3nTapQ@mail.gmail.com>
References: <1423501065-14320-1-git-send-email-tigran.mkrtchyan@desy.de> <CAHQdGtSGS5oJGbjUGBiQ=J6yvx=uQOPzegt2iL-yPVMp3nTapQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: do not initialize back channel with DS
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
> Sent: Monday, February 9, 2015 6:38:35 PM
> Subject: Re: [PATCH] nfs: do not initialize back channel with DS

> Hi Tigran,
> 

Hi Trond,

> On Mon, Feb 9, 2015 at 11:57 AM, Tigran Mkrtchyan
> <tigran.mkrtchyan@desy.de> wrote:
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>>  fs/nfs/nfs4proc.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 2e7c9f7..7f9674d 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -7236,9 +7236,12 @@ static int _nfs4_proc_create_session(struct nfs_client
>> *clp,
>>                 .rpc_cred = cred,
>>         };
>>         int status;
>> +       int flags = SESSION4_PERSIST;
>>
>>         nfs4_init_channel_attrs(&args);
>> -       args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
>> +       if (!is_ds_only_client(clp))
>> +               flags |= SESSION4_BACK_CHAN;
>> +       args.flags = flags;
>>
>>         status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>>         trace_nfs4_create_session(clp, status);
> 
> Why is this useful? If the server doesn't want to create a back
> channel, then it just clears that flag in the csr_flags field in the
> reply.

You are right, there is no much benefit on the server side. The assumption was
that client allocates some resources (request queue, reply cache) associated with
the back channel.

If it's not the case, then just ignore this change.

Tigran.

> 
> Cheers
>  Trond
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
