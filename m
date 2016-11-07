Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:60011
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932237AbcKGQPI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2016 11:15:08 -0500
Subject: Re: [PATCH] net/netfiliter: Fix used uninitialized warn in
 ip_vs_proc_sync_conn()
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        trond.myklebust@primarydata.com
References: <20161107154114.26803-1-shuahkh@osg.samsung.com>
 <20161107154114.26803-3-shuahkh@osg.samsung.com>
 <15645b18-f0ec-81f5-61ed-da8c141e5110@Netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>
From: Shuah Khan <shuahkh@osg.samsung.com>
Message-ID: <6c6def94-90ac-9ec2-4046-4a1edc7a76f2@osg.samsung.com>
Date: Mon, 7 Nov 2016 09:14:52 -0700
MIME-Version: 1.0
In-Reply-To: <15645b18-f0ec-81f5-61ed-da8c141e5110@Netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/07/2016 08:44 AM, Anna Schumaker wrote:
> Hi Shuah,
> 
> On 11/07/2016 10:41 AM, Shuah Khan wrote:
>> Fix the following warn:
>>
>>  net/netfilter/ipvs/ip_vs_sync.c: In function ‘ip_vs_proc_sync_conn’:
>>  net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘opt.init_seq’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>    struct ip_vs_sync_conn_options opt;
>>                                   ^~~
>>  net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘opt.delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>  net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘opt.previous_delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>  net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘*((void *)&opt+12).init_seq’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>  net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘*((void *)&opt+12).delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>  net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘*((void *)&opt+12).previous_delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> Are you sure you put the right commit message on this patch?  The message describes a warning in ip_vs_sync.c, but the patch is for nfs4session.c.
> 
> Thanks,
> Anna

Oops. Sorry about this. Bad cut and paste from make output.
I will resend the patch with the correct changelog

thanks,
-- Shuah

> 
>>
>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
>> ---
>>  fs/nfs/nfs4session.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
>> index b629730..68e700e 100644
>> --- a/fs/nfs/nfs4session.c
>> +++ b/fs/nfs/nfs4session.c
>> @@ -196,7 +196,7 @@ static int nfs4_slot_get_seqid(struct nfs4_slot_table  *tbl, u32 slotid,
>>  static bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl,
>>  		u32 slotid, u32 seq_nr)
>>  {
>> -	u32 cur_seq;
>> +	u32 cur_seq = 0;
>>  	bool ret = false;
>>  
>>  	spin_lock(&tbl->slot_tbl_lock);
>>
> 

