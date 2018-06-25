Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13309 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751745AbeFYPce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:32:34 -0400
Subject: Re: [PATCH nfs-utils] mount: handle ENOSPC in nfs_autonegotiate()
To: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "manjunath.b.patil@oracle.com" <manjunath.b.patil@oracle.com>
References: <1529598860-1960-1-git-send-email-manjunath.b.patil@oracle.com>
 <4ea9eda36b96167203e5943385909278d5e7d5d6.camel@hammerspace.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3ca80799-d540-8a27-3fdd-a64ceca60426@RedHat.com>
Date: Mon, 25 Jun 2018 11:32:33 -0400
MIME-Version: 1.0
In-Reply-To: <4ea9eda36b96167203e5943385909278d5e7d5d6.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/21/2018 12:59 PM, Trond Myklebust wrote:
> On Thu, 2018-06-21 at 09:34 -0700, Manjunath Patil wrote:
>> The server may return NFS4ERR_NOSPC during NFSv4.1+ mount if there is
>> a
>> memory pressure to allocate a DRC slot for session being created. In
>> such cases, try with lower nfs versions, which may succeed as DRC is
>> shared by clients.
>>
>> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>> ---
>>  utils/mount/stropts.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index d1b0708..7e97a88 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -881,6 +881,10 @@ check_result:
>>  	case EINVAL:
>>  		/* A less clear indication that our client
>>  		 * does not support NFSv4 minor version. */
>> +	case ENOSPC:
>> +		/* Server returned NFS4ERR_NOSPC for create session
>> [NFSv4.1+].
>> +		 * Try with lower NFS versions which share DRC
>> amoung clients and
>> +		 * hence low memory may be ok. */
>>  	case EACCES:
>>  		/* An unclear indication that the server
>>  		 * may not support NFSv4 minor version. */
> 
> This comment makes no sense. NFSv4.1 servers also share memory between
> clients, and unlike older versions of NFS, they have ways to reclaim
> that memory (see CB_RECALL_SLOT).
> 
So this is a NACK to this patch... just to make it official

steved.
 
