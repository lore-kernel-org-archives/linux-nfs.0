Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754444AbcFTPs1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 11:48:27 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Anna Schumaker" <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] Trim extra slash in v4 nfs_path
Date: Mon, 20 Jun 2016 11:38:51 -0400
Message-ID: <AE75E577-5BF1-40E5-A9FA-7C40DB029989@redhat.com>
In-Reply-To: <f4f47844-5a28-acbc-0779-fcd66ea6c028@Netapp.com>
References: <1cb38ee043176bca8ded7e18120776f8cf6a722d.1466017326.git.bcodding@redhat.com>
 <f4f47844-5a28-acbc-0779-fcd66ea6c028@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20 Jun 2016, at 11:08, Anna Schumaker wrote:

> Hi Ben,
>
> On 06/15/2016 03:02 PM, Benjamin Coddington wrote:
>> A NFSv4 mount of a subdirectory will show an extra slash (as in
>> 'server://path') in proc's mountinfo which will not match the device 
>> name
>> and path.  This can cause problems for programs searching for the 
>> mount.
>> Fix this by checking for a leading slash in the dentry path, if so 
>> trim
>> away any trailing slashes in the device name.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/namespace.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
>> index c8162c660c44..5551e8ef67fd 100644
>> --- a/fs/nfs/namespace.c
>> +++ b/fs/nfs/namespace.c
>> @@ -98,7 +98,7 @@ rename_retry:
>>  		return end;
>>  	}
>>  	namelen = strlen(base);
>> -	if (flags & NFS_PATH_CANONICAL) {
>> +	if (*end == '/') {
>
> Are we getting here through nfs_show_devname()?  Because it looks like 
> that function is passing 0 for flags instead of NFS_PATH_CANONICAL.

We can get here with or withount NFS_PATH_CANONICAL, through
nfs_show_devname() or nfs4_path() or nfs_do_submount().

>
> Earlier in this function we have a check for:
>     if ((flags & NFS_PATH_CANONICAL) && *end != '/')
>
> Should we be checking if NFS_PATH_CANONICAL is set here, too?

I don't think we need it.

The "if (flags & NFS_PATH_CANONICAL) {" was meant to cover the case 
where
NFS_PATH_CANONICAL had earlier added a leading '/' to the path, and so 
would
trim away any trailing '/' from the base.  So, don't combine server:/ 
and
/path into server://path after adding a leading '/' to the path.

The logic here is simplified such that we should _never_ concat these 
two:
a base:/ and a /path, otherwise we'll have server://path.

Further confusing the matter is that for v3 mounts, the base is 
server:/path
and the path is '/' (which is added by NFS_PATH_CANONICAL), but for v4
mounts the base is server:/ and the path is /path/to/export

Ben

>
> Thanks,
> Anna
>
>>  		/* Strip off excess slashes in base string */
>>  		while (namelen > 0 && base[namelen - 1] == '/')
>>  			namelen--;
>>
