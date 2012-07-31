Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44468 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813Ab2GaHqg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2012 03:46:36 -0400
Message-ID: <50178D59.7010103@parallels.com>
Date: Tue, 31 Jul 2012 11:46:33 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: return negative value in case rpcbind client
 creation error
References: <20120720114849.23572.91010.stgit@localhost.localdomain> <1343689924.8362.4.camel@lade.trondhjem.org>
In-Reply-To: <1343689924.8362.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

31.07.2012 03:12, Myklebust, Trond пишет:
> On Fri, 2012-07-20 at 15:57 +0400, Stanislav Kinsbursky wrote:
>> Without this patch kernel will panic on LockD start, because lockd_up() checks
>> lockd_up_net() result for negative value.
>> >From my pow it's better to return negative value from rpcbind routines instead
>> of replacing all such checks like in lockd_up().
>>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>> ---
>>   net/sunrpc/rpcb_clnt.c |    4 ++--
>>   1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index 92509ff..a70acae 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -251,7 +251,7 @@ static int rpcb_create_local_unix(struct net *net)
>>   	if (IS_ERR(clnt)) {
>>   		dprintk("RPC:       failed to create AF_LOCAL rpcbind "
>>   				"client (errno %ld).\n", PTR_ERR(clnt));
>> -		result = -PTR_ERR(clnt);
>> +		result = PTR_ERR(clnt);
>>   		goto out;
>>   	}
>>
>> @@ -298,7 +298,7 @@ static int rpcb_create_local_net(struct net *net)
>>   	if (IS_ERR(clnt)) {
>>   		dprintk("RPC:       failed to create local rpcbind "
>>   				"client (errno %ld).\n", PTR_ERR(clnt));
>> -		result = -PTR_ERR(clnt);
>> +		result = PTR_ERR(clnt);
>>   		goto out;
>>   	}
>
> Who is supposed to carry this patch? Is it Bruce or is it me?
>

I don't know, Trond. It's up to you and Bruce.
This is a bug fix and the bug is very old. The only reason, why it was found 
just now, is that all the callers of these functions were checking the result 
for zero.
And I agreed with Bruce, that is have to marked for stable branches (at least 
for 3.4-3.5 kernels).

-- 
Best regards,
Stanislav Kinsbursky
