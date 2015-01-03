Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28784 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbACVXi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:23:38 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFS: Ignore transport protocol when detecting server trunking
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtSVgdkDVJcraHRnsmmubLuP=RUjtyV2Zbihva5qf+z+yw@mail.gmail.com>
Date: Sat, 3 Jan 2015 16:23:27 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9E40028A-1BB4-4E84-AA48-C448BEC64D33@oracle.com>
References: <20150103193753.3418.77888.stgit@manet.1015granger.net> <CAHQdGtSVgdkDVJcraHRnsmmubLuP=RUjtyV2Zbihva5qf+z+yw@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 3, 2015, at 4:20 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Sat, Jan 3, 2015 at 2:45 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Detect server trunking across transport protocols. Otherwise, an
>> RDMA mount and a TCP mount of the same server will end up with
>> separate nfs_clients using the same clientid4.
>> 
>> Reported-by: Dai Ngo <dai.ngo@oracle.com>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Re: yesterday's discussion of "[PATCH] NFSv4.1: Fix client id
>> trunking on Linux". This patch seems to address the behavior I
>> mentioned.
>> 
>> fs/nfs/nfs4client.c |    6 ------
>> 1 file changed, 6 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index c0fe338..c7bc38e 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -540,9 +540,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
>>                if (pos->rpc_ops != new->rpc_ops)
>>                        continue;
>> 
>> -               if (pos->cl_proto != new->cl_proto)
>> -                       continue;
>> -
>>                if (pos->cl_minorversion != new->cl_minorversion)
>>                        continue;
>> 
>> @@ -675,9 +672,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
>>                if (pos->rpc_ops != new->rpc_ops)
>>                        continue;
>> 
>> -               if (pos->cl_proto != new->cl_proto)
>> -                       continue;
>> -
>>                if (pos->cl_minorversion != new->cl_minorversion)
>>                        continue;
>> 
>> 
> 
> Yep. Sorry, I only noticed this after I'd written my own version. I'll
> replace mine with this one.

Thanks, much appreciated!

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



