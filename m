Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:42702 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbaEWOYr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 10:24:47 -0400
Received: by mail-qc0-f181.google.com with SMTP id m20so8106319qcx.26
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 07:24:47 -0700 (PDT)
Message-ID: <537F5A1A.9000005@gmail.com>
Date: Fri, 23 May 2014 22:24:26 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Ignore and warn once for more fslocs or more
 uuids
References: <537F38AB.10102@gmail.com> <20140523135435.GK25423@fieldses.org>
In-Reply-To: <20140523135435.GK25423@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/23/2014 21:54, J. Bruce Fields wrote:
> On Fri, May 23, 2014 at 08:01:47PM +0800, Kinglong Mee wrote:
>> If mountd writes more fslocs or more uuids, just ignore and warn once.
> 
> So the current behavior is a leak?

Yes, there is a memory leak for more fslocs or more uuids.

> 
> Have you observed any version of mountd actually writing more than one
> of these?

Sorry, i don't checkout it.
I just review the codes, and rewrit nfs-utils to writing more fslocs or uuids.

> 
> If not, I'd prefer to return an error.

You mean return -EINVAL instead of ignoring it with return 0? 

Although, i miss checking the more "secinfo" in secinfo_parse() right now,
for no memory leak. I will adds it after decides how to fix above.

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/export.c | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>> index 90d37b6..1d56ae3 100644
>> --- a/fs/nfsd/export.c
>> +++ b/fs/nfsd/export.c
>> @@ -394,6 +394,12 @@ fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
>>  	int len;
>>  	int migrated, i, err;
>>  
>> +	/* utils writes more fslocs than one */
>> +	if (fsloc->locations) {
>> +		WARN_ON_ONCE(1);
>> +		return 0;
>> +	}
>> +
>>  	/* listsize */
>>  	err = get_uint(mesg, &fsloc->locations_count);
>>  	if (err)
>> @@ -485,6 +491,12 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
>>  {
>>  	int len;
>>  
>> +	/* utils writes more uuid than one */
>> +	if (*puuid) {
>> +		WARN_ON_ONCE(1);
>> +		return 0;
>> +	}
>> +
>>  	/* expect a 16 byte uuid encoded as \xXXXX... */
>>  	len = qword_get(mesg, buf, PAGE_SIZE);
>>  	if (len != EX_UUID_LEN)
>> -- 
>> 1.9.0
>>
> 
