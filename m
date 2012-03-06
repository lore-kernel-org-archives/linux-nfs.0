Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17920 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932353Ab2CFRPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 12:15:48 -0500
Message-ID: <4F564642.5020404@netapp.com>
Date: Tue, 06 Mar 2012 12:15:46 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4: parse and display server implementation ids
References: <1329510026-30403-1-git-send-email-dros@netapp.com> <1329510026-30403-3-git-send-email-dros@netapp.com> <4F522623.3070709@netapp.com> <1330904007.14357.13.camel@lade.trondhjem.org> <F2EBB85C-C7D1-44BF-8863-7CA5FC5203C5@netapp.com>
In-Reply-To: <F2EBB85C-C7D1-44BF-8863-7CA5FC5203C5@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/06/2012 12:08 PM, Adamson, Dros wrote:

> 
> On Mar 4, 2012, at 6:33 PM, Myklebust, Trond wrote:
> 
>> On Sat, 2012-03-03 at 09:09 -0500, Bryan Schumaker wrote:
>>> Hi Dros,
>>>
>>> On 02/17/2012 03:20 PM, Weston Andros Adamson wrote:
>>>
>>>> Shows the implementation ids in /proc/self/mountstats.  This doesn't break
>>>> the nfs-utils mountstats tool.
>>>>
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>>> fs/nfs/client.c           |    1 +
>>>> fs/nfs/nfs4proc.c         |   21 +++++++++++++++++++++
>>>> fs/nfs/nfs4xdr.c          |   42 +++++++++++++++++++++++++++++++++++++-----
>>>> fs/nfs/super.c            |    8 ++++++++
>>>> include/linux/nfs_fs_sb.h |    2 ++
>>>> include/linux/nfs_xdr.h   |   15 +++++++--------
>>>> 6 files changed, 76 insertions(+), 13 deletions(-)
>>>>
>>>
>>> <snip>
>>>
>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>> index d05024a..5462225 100644
>>>> --- a/fs/nfs/super.c
>>>> +++ b/fs/nfs/super.c
>>>> @@ -809,6 +809,14 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
>>>>
>>>> 	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
>>>>
>>>> +	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
>>>> +		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
>>>
>>>
>>> "struct nfs41_impl_id" is only defined when CONFIG_NFS_V4_1 is enabled, so if I compile without NFS 4.1 enabled I get this error:
>>>
>>>  CC [M]  fs/nfs/super.o
>>> /home/bjschuma/linux/modules/fs/nfs/super.c: In function 'nfs_show_stats':
>>> /home/bjschuma/linux/modules/fs/nfs/super.c:843:14: error: dereferencing pointer to incomplete type
>>> /home/bjschuma/linux/modules/fs/nfs/super.c:843:29: error: dereferencing pointer to incomplete type
>>> /home/bjschuma/linux/modules/fs/nfs/super.c:844:14: error: dereferencing pointer to incomplete type
>>> /home/bjschuma/linux/modules/fs/nfs/super.c:844:37: error: dereferencing pointer to incomplete type
>>> make[3]: *** [fs/nfs/super.o] Error 1
> 
> Oops!  Good catch Bryan!
> 
>>
>> Hi Bryan & Dros
>>
>> I've applied the following patch to fix this issue. Please advise if
>> you're still seeing compile problems when it is applied.
>>
>> 8<----------------------------------------------------------------------------
>> From d032769b833d8fbaaa620a54300979dd5881d493 Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date: Sun, 4 Mar 2012 18:12:57 -0500
>> Subject: [PATCH] NFS: Fix a compile issue when !CONFIG_NFS_V4_1
>>
>> The attempt to display the implementation ID needs to be conditional on
>> whether or not CONFIG_NFS_V4_1 is defined
>>
>> Reported-by: Bryan Schumaker <Bryan.Schumaker@netapp.com>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>> fs/nfs/super.c |   22 +++++++++++++++-------
>> 1 files changed, 15 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 3935a37..61419c9 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -785,8 +785,22 @@ static void show_pnfs(struct seq_file *m, struct nfs_server *server)
>> 	else
>> 		seq_printf(m, "not configured");
>> }
>> +
>> +static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
>> +{
>> +	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
>> +		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
>> +		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
>> +			   "date='%llu,%u'",
>> +			   impl_id->name, impl_id->domain,
>> +			   impl_id->date.seconds, impl_id->date.nseconds);
>> +	}
>> +}
>> #else
>> static void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
>> +static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
>> +{
>> +}
>> #endif
>> #endif
>>
>> @@ -836,13 +850,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
>>
>> 	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
>>
>> -	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
>> -		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
>> -		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
>> -			   "date='%llu,%u'",
>> -			   impl_id->name, impl_id->domain,
>> -			   impl_id->date.seconds, impl_id->date.nseconds);
>> -	}
>> +	show_implementation_id(m, nfss);
>>
>> 	seq_printf(m, "\n\tcaps:\t");
>> 	seq_printf(m, "caps=0x%x", nfss->caps);
>> -- 
>> 1.7.7.6
> 
> Works for me.  I need to test with different CONFIG opts more often!


That's actually how I found this.  I set up Jenkins to change all the nfs CONFIG options to make sure I had everything covered for my modules patches.  I've added compile testing to my normal nightly tests now, so these issuse should be caught faster.

- Bryan

> 
> -dros


