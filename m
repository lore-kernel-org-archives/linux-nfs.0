Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33718 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbbEFNiU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:38:20 -0400
Received: by pacwv17 with SMTP id wv17so9843940pac.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 06:38:20 -0700 (PDT)
Message-ID: <554A1947.5000301@gmail.com>
Date: Wed, 06 May 2015 21:38:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Scott Mayhew <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.mountd: Remove duplicate and invalid secinfo setting
References: <552FB045.80604@gmail.com> <20150417181503.GT63078@tonberry.usersys.redhat.com>
In-Reply-To: <20150417181503.GT63078@tonberry.usersys.redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 4/18/2015 2:15 AM, Scott Mayhew wrote:
> On Thu, 16 Apr 2015, Kinglong Mee wrote:
> 
>> NFSD return reply of client's SECINFO_NO_NAME request with four
>> security information number as, 1 1 0 0
>>
>> It's caused by commit 4a1ad4aa30,
>> "mountd: Enable all auth flavors on pseudofs exports"
>>
>> This patch removes duplicate secinfo and invalid secinfo (zero).
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> 
> This is because flav_map has both AUTH_UNIX/AUTH_SYS and
> AUTH_NULL/AUTH_NONE.  I had discussed it with Steve, but since I didn't
> observe any problems caused by it in my testing I just left them in.
> 
> Acked-by: Scott Mayhew <smayhew@redhat.com>

Also, this one?

thanks,
Kinglong Mee

> 
>> ---
>>  support/nfs/exports.c | 2 +-
>>  utils/mountd/v4root.c | 3 +++
>>  2 files changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
>> index 761a046..0aea6f1 100644
>> --- a/support/nfs/exports.c
>> +++ b/support/nfs/exports.c
>> @@ -408,7 +408,7 @@ int secinfo_addflavor(struct flav_info *flav, struct exportent *ep)
>>  	struct sec_entry *p;
>>  
>>  	for (p=ep->e_secinfo; p->flav; p++) {
>> -		if (p->flav == flav)
>> +		if (p->flav == flav || p->flav->fnum == flav->fnum)
>>  			return p - ep->e_secinfo;
>>  	}
>>  	if (p - ep->e_secinfo >= SECFLAVOR_COUNT) {
>> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
>> index 429ebb8..d521725 100644
>> --- a/utils/mountd/v4root.c
>> +++ b/utils/mountd/v4root.c
>> @@ -69,6 +69,9 @@ set_pseudofs_security(struct exportent *pseudo, int flags)
>>  	for (flav = flav_map; flav < flav_map + flav_map_size; flav++) {
>>  		struct sec_entry *new;
>>  
>> +		if (!flav->fnum)
>> +			continue;
>> +
>>  		i = secinfo_addflavor(flav, pseudo);
>>  		new = &pseudo->e_secinfo[i];
>>  
>> -- 
>> 2.3.5
>>
> 
> 
