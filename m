Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24570 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753130Ab1LTKbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Dec 2011 05:31:32 -0500
Message-ID: <4EF063EB.6030104@parallels.com>
Date: Tue, 20 Dec 2011 14:31:07 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Glauber Costa <glommer@parallels.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [Devel] [PATCH] SUNRPC: search for service transports in network
 namespace context
References: <20111220101419.5673.21926.stgit@localhost6.localdomain6> <4EF062B1.3030401@parallels.com>
In-Reply-To: <4EF062B1.3030401@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

20.12.2011 14:25, Glauber Costa пишет:
> On 12/20/2011 03:14 PM, Stanislav Kinsbursky wrote:
>> Service transports are parametrized by network namespace. And thus lookup of
>> transport instance have to take network namespace into account.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>    fs/lockd/svc.c                  |    2 +-
>>    fs/nfsd/nfsctl.c                |    4 ++--
>>    include/linux/sunrpc/svc_xprt.h |    3 ++-
>>    net/sunrpc/svc_xprt.c           |    6 +++++-
>>    4 files changed, 10 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>> index c061b9a..ff379ff 100644
>> --- a/fs/lockd/svc.c
>> +++ b/fs/lockd/svc.c
>> @@ -193,7 +193,7 @@ static int create_lockd_listener(struct svc_serv *serv, const char *name,
>>    {
>>    	struct svc_xprt *xprt;
>>
>> -	xprt = svc_find_xprt(serv, name, family, 0);
>> +	xprt = svc_find_xprt(serv, name,&init_net, family, 0);
>>    	if (xprt == NULL)
>>    		return svc_create_xprt(serv, name,&init_net, family, port,
>>    						SVC_SOCK_DEFAULTS);
>
> I might be missing something, but isn't it (at least part of it) already
> merged in commit fc5d00b04a3a58cac8620403dfe9f43f72578ec1 ?
>

Nope, those one was parameterizing transport creation by network namespace.
This one is parameterizing search in poll of existent service transports by 
network namespace.

-- 
Best regards,
Stanislav Kinsbursky
