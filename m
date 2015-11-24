Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34662 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbbKXBgC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 20:36:02 -0500
Received: by oies6 with SMTP id s6so1560937oie.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2015 17:36:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5653BB2C.4040209@talpey.com>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
	<20151123222030.13040.19373.stgit@klimt.1015granger.net>
	<5653B1A6.3010707@talpey.com>
	<BABDB763-B4D6-4538-82FB-11F494BAC27C@oracle.com>
	<5653BB2C.4040209@talpey.com>
Date: Mon, 23 Nov 2015 20:36:01 -0500
Message-ID: <CAHQdGtTWkCoaehHbYwHSOQg0zn96dT7S0W3pERALvVy3d7uyZw@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] svcrdma: Define maximum number of backchannel requests
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tom Talpey <tom@talpey.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2015 at 8:19 PM, Tom Talpey <tom@talpey.com> wrote:
> On 11/23/2015 8:09 PM, Chuck Lever wrote:
>>
>>
>>> On Nov 23, 2015, at 7:39 PM, Tom Talpey <tom@talpey.com> wrote:
>>>
>>> On 11/23/2015 5:20 PM, Chuck Lever wrote:
>>>>
>>>> Extra resources for handling backchannel requests have to be
>>>> pre-allocated when a transport instance is created. Set a limit.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>   include/linux/sunrpc/svc_rdma.h          |    5 +++++
>>>>   net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++++-
>>>>   2 files changed, 10 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/svc_rdma.h
>>>> b/include/linux/sunrpc/svc_rdma.h
>>>> index f869807..478aa30 100644
>>>> --- a/include/linux/sunrpc/svc_rdma.h
>>>> +++ b/include/linux/sunrpc/svc_rdma.h
>>>> @@ -178,6 +178,11 @@ struct svcxprt_rdma {
>>>>   #define RPCRDMA_SQ_DEPTH_MULT   8
>>>>   #define RPCRDMA_MAX_REQUESTS    32
>>>>   #define RPCRDMA_MAX_REQ_SIZE    4096
>>>> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
>>>
>>>
>>> Why is this a config option? Why wouldn't you always want
>>> this? It's needed for any post-1990 NFS dialect.
>>
>>
>> I think some distros want to be able to compile out NFSv4.x
>> on small systems, and take all the backchannel cruft with it.
>
>
> So shouldn't it follow the NFSv4.x config options then?

It does. Why the question?
