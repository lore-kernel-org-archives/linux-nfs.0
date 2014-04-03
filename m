Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:65266 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbaDCQCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Apr 2014 12:02:54 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so2053029pab.23
        for <linux-nfs@vger.kernel.org>; Thu, 03 Apr 2014 09:02:53 -0700 (PDT)
Message-ID: <533D8629.10907@gmail.com>
Date: Thu, 03 Apr 2014 19:02:49 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory names.
References: <20140403164652.5d7770ad@notabene.brown> <20140403130909.GA24700@fieldses.org>
In-Reply-To: <20140403130909.GA24700@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/03/2014 04:09 PM, J. Bruce Fields wrote:
> On Thu, Apr 03, 2014 at 04:46:52PM +1100, NeilBrown wrote:
>>
>> Hi,
>>  I came across an interesting issue recently.
>>
>> Suppose you have a filesystem which supports case-insensitive file names
>> (like VFAT, but in this particular case 'NSS' - Novell Storage Services).
>>
>> And support you export some subdirectory (or sub-volume) using a
>> non-canonical name.
>> i.e. you "mkdir /path/export", the put "/path/EXPORT" in /etc/exports and
>> mount  server:/path/EXPORT from some client.
>>
>> This all works until the export cache times out and the kernel asks mountd
>> if "/path/export" is exported.  mountd says "no" and suddenly all accesses
>> fail.
>>
>> I don't think much of case-insensitive file names, but I suspect we should
>> either make this work, it issue a warning as to why it is failing.
>> A simple work around is to export the canonical name and use it when
>> mounting.  But if the sysadmin doesn't know they need to, they are unlikely
>> to guess.
>>
>> I don't think there is any API to test if a name is canonical, or to get the
>> canonical name, so I cannot see any way in advance to see if this problem
>> situation has arisen.  So the only option I can think of is to fix it.
>>
>> The following patch (or something much like it for an older nfs-utils) seems
>> to do the trick.
>>
>> What do people think?  Is this a reasonable thing to do?  Is it likely to
>> have negative consequences that I haven't thought of?
> 
> Neat-o.
> 
> Are we adding a stat of every export in the export table where there
> wasn't one before?  But those should typically be cached, so maybe
> there's no problem.
> 
> I'm not super-fond of the combining the comparison of two paths and
> truncating of one into the same function, though I see why it's
> convenient.
> 
> --b.
> 
>>
>> Thanks,
>> NeilBrown
>>
>>
>>
>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>> index 9a1bb2767ac2..2d91db76b867 100644
>> --- a/utils/mountd/cache.c
>> +++ b/utils/mountd/cache.c
>> @@ -377,6 +377,28 @@ static char *next_mnt(void **v, char *p)
>>  	return me->mnt_dir;
>>  }
>>  
>> +static int same_path(char *child, char *parent, int len)
>> +{
>> +	static char p[PATH_MAX];
>> +	struct stat sc, sp;
>> +	if (len <= 0)
>> +		len = strlen(child);
>> +	strncpy(p, child, len);
>> +	p[len] = 0;
>> +	if (strcmp(p, parent) == 0)
>> +		return 1;
>> +

Addressing Bruce concern, perhaps you would like to
also  stricmp the names, so to not lstat on all export
entries.

+	if (stricmp(p, parent) =! 0)
+		return 0;

>> +	if (lstat(p, &sc) != 0)
>> +		return 0;
>> +	if (lstat(parent, &sp) != 0)
>> +		return 0;
>> +	if (sc.st_dev != sp.st_dev)
>> +		return 0;
>> +	if (sc.st_ino != sp.st_ino)
>> +		return 0;

Hard links on directories any one ? ;-)

Thanks
Boaz

>> +	return 1;
>> +}
>> +
>>  static int is_subdirectory(char *child, char *parent)
>>  {
>>  	/* Check is child is strictly a subdirectory of
>> @@ -387,7 +409,7 @@ static int is_subdirectory(char *child, char *parent)
>>  	if (strcmp(parent, "/") == 0 && child[1] != 0)
>>  		return 1;
>>  
>> -	return (strncmp(child, parent, l) == 0 && child[l] == '/');
>> +	return (same_path(child, parent, l) && child[l] == '/');
>>  }
>>  
>>  static int path_matches(nfs_export *exp, char *path)
>> @@ -396,7 +418,7 @@ static int path_matches(nfs_export *exp, char *path)
>>  	 * exact match, or does the export have CROSSMOUNT, and path
>>  	 * is a descendant?
>>  	 */
>> -	return strcmp(path, exp->m_export.e_path) == 0
>> +	return same_path(path, exp->m_export.e_path, 0)
>>  		|| ((exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
>>  		    && is_subdirectory(path, exp->m_export.e_path));
>>  }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

