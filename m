Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:18097 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbaEVD21 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 23:28:27 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v4 20/24] xprtrdma: Reset connection timeout after successful reconnect
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAABAsM5m_CT7qUv4Xbm+LKoSZaia55APO3kgnt7Ti1x24gsrbg@mail.gmail.com>
Date: Wed, 21 May 2014 23:28:24 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <D839BB6A-CDD2-47B6-B758-F89296F4A147@oracle.com>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net> <20140522005707.27190.2035.stgit@manet.1015granger.net> <CAABAsM5m_CT7qUv4Xbm+LKoSZaia55APO3kgnt7Ti1x24gsrbg@mail.gmail.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 21, 2014, at 10:07 PM, Trond Myklebust <trondmy@gmail.com> wrote:

> On Wed, May 21, 2014 at 8:57 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> If the new connection is able to make forward progress, reset the
>> re-establish timeout. Otherwise it keeps growing even if disconnect
>> events are rare.
>> 
>> The same behavior as TCP is adopted: reconnect immediately if the
>> transport instance has been able to make some forward progress.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> net/sunrpc/xprtrdma/rpc_rdma.c |    2 ++
>> 1 files changed, 2 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index dc4a826..1334646 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -770,6 +770,8 @@ repost:
>> 
>>        /* from here on, the reply is no longer an orphan */
>>        req->rl_reply = rep;
>> +       if (xprt->reestablish_timeout)
>> +               xprt->reestablish_timeout = 0;
> 
> What's the point of making this conditional?

Good catch. I’ll remove the conditional.

I copied this straight from xs_tcp_data_ready().

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



