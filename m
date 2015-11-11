Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:60801 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbbKKTMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2015 14:12:45 -0500
Subject: Re: [GIT PULL] Please pull an NFSoRDMA client bugfix
To: Steve Wise <swise@opengridcomputing.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>
References: <560AFB37.4080609@Netapp.com>
 <01c101d117ee$4f87f320$ee97d960$@opengridcomputing.com>
CC: <linux-nfs@vger.kernel.org>, Chuck Lever <chuck.lever@oracle.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <56439320.1040103@Netapp.com>
Date: Wed, 11 Nov 2015 14:12:32 -0500
MIME-Version: 1.0
In-Reply-To: <01c101d117ee$4f87f320$ee97d960$@opengridcomputing.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

On 11/05/2015 12:20 PM, Steve Wise wrote:
> Anna and Trond,
> 
> Does it make sense for this to be pushed into stable as well?  It can cause a touch-after-free crash on iWARP transports. 

Do you know if any users are hitting this?  I can push it to stable, but only if it's being hit in the wild.

Anna

> 
> Steve.
> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Anna Schumaker
>> Sent: Tuesday, September 29, 2015 3:57 PM
>> To: Trond Myklebust
>> Cc: linux-nfs@vger.kernel.org; Steve Wise
>> Subject: [GIT PULL] Please pull an NFSoRDMA client bugfix
>>
>> Hi Trond,
>>
>> The following changes since commit d0f36c46deea97bd16b9277be2f1acac74d76037:
>>
>>   xprtrdma: take HCA driver refcount at client (2015-08-05 16:22:56 -0400)
>>
>> are available in the git repository at:
>>
>>   git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-4.3-2
>>
>> for you to fetch changes up to 72c021738252dde5849d575a650239d6404930ee:
>>
>>   xprtrdma: disconnect and flush cqs before freeing buffers (2015-09-28 10:42:35 -0400)
>>
>> Thanks,
>> Anna
>>
>> ----------------------------------------------------------------
>> Steve Wise (1):
>>       xprtrdma: disconnect and flush cqs before freeing buffers
>>
>>  net/sunrpc/xprtrdma/transport.c | 2 +-
>>  net/sunrpc/xprtrdma/verbs.c     | 9 ++++++---
>>  2 files changed, 7 insertions(+), 4 deletions(-)
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

