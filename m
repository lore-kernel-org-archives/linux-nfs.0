Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59057 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaGaM4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2014 08:56:34 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so3452786pdb.3
        for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2014 05:56:34 -0700 (PDT)
Message-ID: <53DA3CED.3060105@gmail.com>
Date: Thu, 31 Jul 2014 20:56:13 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: [PATCH] NFSD: Decrease nfsd_users in nfsd_startup_generic fail
References: <53D8F26D.8070304@gmail.com> <20140730141648.GE26316@fieldses.org>
In-Reply-To: <20140730141648.GE26316@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/30/2014 22:16, J. Bruce Fields wrote:
> Thanks!
> 
> On Wed, Jul 30, 2014 at 09:26:05PM +0800, Kinglong Mee wrote:
>> If nfsd_startup_generic fail, nfsd_users isn't decreased right now.
> 
> Looks like that should only fail in out of memory cases?

Yes, it is.
I found this problem through reviewing code.

> 
>> NFSD restarts will return 0 at the first nfsd_users checking,
>> after that, nfs4_state_start_net() will meet a bad laundry_wq
>> (I meet NULL), after nfsd4_grace timeout, the kernel will crash.
> 
> So this was introduced with 4539f14981ce02d48b212786a41c8bcfb62851b4
> "nfsd: replace boolean nfsd_up flag by users counter".

Yes, I forget adding it.

thanks,
Kinglong Mee

>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfssvc.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>> index 5d026dc..752d56b 100644
>> --- a/fs/nfsd/nfssvc.c
>> +++ b/fs/nfsd/nfssvc.c
>> @@ -221,7 +221,8 @@ static int nfsd_startup_generic(int nrservs)
>>  	 */
>>  	ret = nfsd_racache_init(2*nrservs);
>>  	if (ret)
>> -		return ret;
>> +		goto dec_users;
>> +
>>  	ret = nfs4_state_start();
>>  	if (ret)
>>  		goto out_racache;
>> @@ -229,6 +230,8 @@ static int nfsd_startup_generic(int nrservs)
>>  
>>  out_racache:
>>  	nfsd_racache_shutdown();
>> +dec_users:
>> +	nfsd_users--;
>>  	return ret;
>>  }
>>  
>> -- 
>> 1.9.3
>>
> 
