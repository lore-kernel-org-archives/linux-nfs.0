Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:32833 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247AbbDVLLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2015 07:11:39 -0400
Received: by pdbnk13 with SMTP id nk13so271171268pdb.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2015 04:11:38 -0700 (PDT)
Message-ID: <553781E2.1000900@gmail.com>
Date: Wed, 22 Apr 2015 19:11:30 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
References: <553663B7.7030506@gmail.com> <20150421215417.GE13782@fieldses.org>
In-Reply-To: <20150421215417.GE13782@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/22/2015 5:54 AM, J. Bruce Fields wrote:
> On Tue, Apr 21, 2015 at 10:50:31PM +0800, Kinglong Mee wrote:
>> If there are some mount points(not exported for nfs) under
>> a pseudo root, after client's operation of those entry under
>> the root, anyone can unmount those mount points until nfsd stop.
>>
>> # cat /etc/exports
>> /nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
>> /nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
>> # ll /nfs/
>> total 0
>> drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
>> drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
>> drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
>> # mount /dev/sde /nfs/test
>> # df
>> Filesystem                      1K-blocks    Used Available Use% Mounted on
>> ......
>> /dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
>> /dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
>> /dev/sde                           999320    1284    929224   1% /nfs/test
>> # mount -t nfs 127.0.0.1:/nfs/ /mnt
>> # ll /mnt/*/
>> /mnt/pnfs/:
>> total 0
>> -rw-r--r--. 1 root root 0 Apr 21 22:23 attr
>> drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp
>>
>> /mnt/xfs/:
>> total 0
>> # umount /nfs/test/
>> umount: /nfs/test/: target is busy
>>         (In some cases useful info about processes that
>>          use the device is found by lsof(8) or fuser(1).)
>>
>> I don't think that's user expect, they want umount /nfs/test/.
> 
> I agree that this is annoying.
> 
>> It's caused by exports cache of nfsd holds the reference of
>> the path (here is /nfs/test/), so, it can't umounted until nfsd stop.
> 
> A cache flush (exportfs -f) should also do the job, as long as you
> then manage to unmount before the cache entry is re-added.  (So I
> suppose if you wanted to be completely safe:
> 
> 	exportfs -f
> 	killall -STOP  rpc.mountd
> 	umount /nfs/test/
> 	killall -CONT rpc.mountd
> )

Yes, that's right.

> 
>> There is one strange thing exist, the export cache status of
>> /nfs/test/ is CACHE_NEGATIVE, also hold the reference of the path.
>> I think nfsd should not hold the reference when CACHE_NEGATIVE.
>>
>> I can't find a better way to put the reference, just path it after
>> svc_export_update().
> 
> Unfortunately ex_path is part of the key--it's what we need to do
> lookups in this cache.  I'm surprised something like ls /mnt/ still
> works after this.

I just do some simplify tests, and can't make sure everything is right.

> 
> I'm not sure what to do.  I wonder if we really need the struct path as
> part of the key, or if we could get away with just a string path?
> That's what we're actually passing to userspace, after all.

I have do a simplify grep of ex_path, it is used in many places.
I don't think a string path can resolve the problem.
Reference of dentry/mnt is like a cache, avoids re-finding of them,
it is necessary to store them in svc_export.

Neil points out another way of 'fs_pin', I will check that.

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> Any comments are welcome, thanks.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/export.c | 12 +++++++++---
>>  1 file changed, 9 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>> index c3e3b6e..5595cffc7 100644
>> --- a/fs/nfsd/export.c
>> +++ b/fs/nfsd/export.c
>> @@ -793,9 +793,15 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
>>  	int hash = svc_export_hash(old);
>>  
>>  	ch = sunrpc_cache_update(old->cd, &new->h, &old->h, hash);
>> -	if (ch)
>> -		return container_of(ch, struct svc_export, h);
>> -	else
>> +	if (ch) {
>> +		struct svc_export *exp = container_of(ch, struct svc_export, h);
>> +		if (test_bit(CACHE_NEGATIVE, &exp->h.flags)) {
>> +			path_put(&exp->ex_path);
>> +			exp->ex_path.mnt = NULL;
>> +			exp->ex_path.dentry = NULL;
>> +		}
>> +		return exp;
>> +	} else
>>  		return NULL;
>>  }
>>  
>> -- 
>> 2.3.5
> 
