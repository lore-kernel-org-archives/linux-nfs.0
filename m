Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758045Ab2CFA1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 19:27:18 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q260RIL2016725
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:27:18 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q260RHhj022767
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:27:18 -0500
Message-ID: <4F5559EA.7010206@RedHat.com>
Date: Mon, 05 Mar 2012 19:27:22 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
References: <1330976165-19849-1-git-send-email-steved@redhat.com> <1330976165-19849-2-git-send-email-steved@redhat.com> <20120305212015.GA21904@us.ibm.com>
In-Reply-To: <20120305212015.GA21904@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 04:20 PM, Malahal Naineni wrote:
> Steve Dickson [steved@redhat.com] wrote:
>> So path names are found during umounts, normalize
>> path names by removing any extra slashes and add
>> a lead slash if one does not exist.
>>
>> This normalization only has to occur when the mtab
>> and /proc/mounts are not the same file.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/nfsumount.c |   64 +++++++++++++++++++++++++++++++++++++++++++++-
>>  1 files changed, 62 insertions(+), 2 deletions(-)
>>
>> diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
>> index 3538d88..0f77261 100644
>> --- a/utils/mount/nfsumount.c
>> +++ b/utils/mount/nfsumount.c
>> @@ -140,6 +140,52 @@ static int del_mtab(const char *spec, const char *node)
>>  }
>>
>>  /*
>> + * To ensure the path is found during unmounts, strip
>> + * off the multiple '/' or add a '/' if one does not exist.
>> + */
>> +static inline char *
>> +normalize_path(char *spec) 
>> +{
>> +	char *colen, *ptr, *str, *dev;
>> +
>> +	if ((colen = strchr(spec, ':')) == NULL)
>> +		return NULL;
>> +
>> +	if (*(colen + 1) != '/') {
>> +		dev = str = malloc(strlen(spec) + 2);
>> +		if (dev == NULL) 
>> +			return NULL;
>> +
>> +		ptr = spec;
>> +		while (ptr <= colen)
>> +			*(str++) = *(ptr++);
>> +		*str++='/';
>> +		while (*ptr)
>> +			*(str++) = *(ptr++);
>> +		*str='\0';
>> +
>> +		return dev;
>> +	}
>> +
>> +	if (strstr(spec, "//") != NULL) {
>> +		dev = strdup(spec);
>> +		if (dev == NULL)
>> +			return NULL;
>> +
>> +		colen = strchr(dev, ':');
>> +		ptr = (colen +1);
>> +		while (*ptr && *(ptr+1) == '/')
>> +			ptr++;
>> +		while (*ptr)
>> +			*(++colen) = *(ptr++);
>> +		*(colen+1) = '\0';
>> +
>> +		return dev;
>> +	} 
>> +	return NULL;
>> +}
>> +
>> +/*
>>   * Detect NFSv4 mounts.
>>   *
>>   * Consult /proc/mounts to determine if the mount point
>> @@ -154,6 +200,7 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
>>  	struct mntentchn *pmc;
>>  	struct mount_options *options;
>>  	int retval;
>> +	char *normpath=NULL;
>>
>>  	retval = -1;
>>  	pmc = getprocmntdirbackward(mc->m.mnt_dir, NULL);
>> @@ -171,8 +218,20 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
>>  		 */
>>  		while (pmc->m.mnt_fsname[nlen - 1] == '/')
>>  			nlen--;
>> -		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
>> -			continue;
>> +		/*
>> +		 * When the mtab and /proc/mounts are not the same
>> +		 * file, normalize the path in the mtab if needed.
>> +		 */
>> +		if (mtab_is_writable())
>> +			normpath = normalize_path(mc->m.mnt_fsname);
>> +
>> +		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0) {
>> +			/* Is there a normalized path, if so compare that one too */
>> +			if (normpath == NULL)
>> +				continue;
>> +			if (strncmp(pmc->m.mnt_fsname, normpath, nlen) != 0)
>> +				continue;
> 
> You need to free normpath here before the "continue".
> 
> Also, when you normalize, why not go the extra mile of doing it all the
> way as the patch I posted? I wanted to cover specs like
> "host:/server/../home/./blah". This patch only does partial
> normalization. The original patch also normalizes /proc/mount entry's
> pathname (this avoids dealing with trailing '/' hack that exists now).
I just do not see the need for that type of complexity... Maybe I'm
being a bit naive, but I see two problems here. One, v4 mounts 
with multiple slashes and two v4 mounts without any slashes... 

Now both of our patches do address those issues but mine only
addresses those issues and no, it does not go the "extra mile" 
of addressing '..' in path names, but does it need to? Is 
there really an use case where people export things with ".."
in the path? 

Sometimes going the just extra mile just brings more pain... 
for no reason... and believe me I'm no runner...  8-) 

steved.

