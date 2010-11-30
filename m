Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16299 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab0K3QCZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 11:02:25 -0500
Message-ID: <4CF5200E.3030108@panasas.com>
Date: Tue, 30 Nov 2010 18:02:22 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSv4: Send unmapped uid/gids to the server when
 using auth_sys
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>	 <1291085863-3234-2-git-send-email-Trond.Myklebust@netapp.com>	 <1291085863-3234-3-git-send-email-Trond.Myklebust@netapp.com>	 <1291085863-3234-4-git-send-email-Trond.Myklebust@netapp.com>	 <1291085863-3234-5-git-send-email-Trond.Myklebust@netapp.com>	 <4CF4C798.2000009@panasas.com> <1291123037.3204.5.camel@heimdal.trondhjem.org>
In-Reply-To: <1291123037.3204.5.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/30/2010 03:17 PM, Trond Myklebust wrote:
> On Tue, 2010-11-30 at 11:44 +0200, Boaz Harrosh wrote:
>> On 11/30/2010 04:57 AM, Trond Myklebust wrote:
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>  fs/nfs/client.c           |   16 ++++++++++++++++
>>>  fs/nfs/idmap.c            |   21 +++++++++++++--------
>>>  fs/nfs/nfs4proc.c         |    8 +++++++-
>>>  include/linux/nfs_fs_sb.h |    1 +
>>>  4 files changed, 37 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index 0870d0d..fb84771 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -58,6 +58,11 @@ static LIST_HEAD(nfs_volume_list);
>>>  static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
>>>  
>>>  /*
>>> + * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
>>> + */
>>> +static int nfs4_disable_idmapping = 0;
>>
>> The double negative is a bit hard. I had to read it 3 times to
>> register. Perhaps consider reversing the name and the default
>>
>> +static int nfs4_enable_idmapping = 1;
> 
> No. That suggests that idmapping is optional and that you are fine not
> enabling it. What we're doing here is adding in a hack that is not
> tolerated by most servers. People _should_ have to think before
> disabling idmapping.
> 

I'm not suggesting anything. I've propose an identical system that
avoids the confusion I had when I first read it in the morning
before my coffee. But if for you default means zero and override/hack
means set to 1, then sure. Just that I never thought that.
Default is 1, set 0 to disable is just as fine for me.

> Cheers
>   Trond
> 

Thanks
Boaz
