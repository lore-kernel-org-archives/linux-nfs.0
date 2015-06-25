Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33691 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbFYOqd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:46:33 -0400
Message-ID: <558C143E.9080203@gmail.com>
Date: Thu, 25 Jun 2015 22:46:22 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 6/6 v5] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
References: <5581266C.9080404@gmail.com> <55812768.1080908@gmail.com> <20150619210956.GN17109@ZenIV.linux.org.uk>
In-Reply-To: <20150619210956.GN17109@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 6/20/2015 5:09 AM, Al Viro wrote:
> On Wed, Jun 17, 2015 at 03:53:12PM +0800, Kinglong Mee wrote:
>>  static void expkey_put(struct kref *ref)
>>  {
>>  	struct svc_expkey *key = container_of(ref, struct svc_expkey, h.ref);
>>  
>>  	if (test_bit(CACHE_VALID, &key->h.flags) &&
>> -	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
>> -		path_put(&key->ek_path);
>> -	auth_domain_put(key->ek_client);
>> -	kfree(key);
>> +	    !test_bit(CACHE_NEGATIVE, &key->h.flags)) {
>> +		rcu_read_lock();
>> +		complete(&key->ek_done);
>> +		pin_kill(&key->ek_pin);
>> +	} else
>> +		expkey_destroy(key);
>>  }
> 
>> +static void expkey_pin_kill(struct fs_pin *pin)
>> +{
>> +	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
>> +
>> +	if (!completion_done(&key->ek_done)) {
>> +		schedule_work(&key->ek_work);
>> +		wait_for_completion(&key->ek_done);
>> +	}
>> +	path_put_unpin(&key->ek_path, &key->ek_pin);
>> +	expkey_destroy(key);
>> +}
> 
> So basically you want umount(2) to hang until all references are gone.
> How long can they stick around and, more to the point, what happens
> if some sucker does path_get(&key->ek_path) while umount(2) had been
> waiting?  You'll drop the reference to svc_export you'd copied ->ek_path
> from and get through the whole dance, letting umount(2) go.
> 
> Now what?  Sure, with your previous patch vfsmount will survive - no oopsen
> there.  However, you have had umount run to completion, with filesystem
> still not shut down.  This is badly broken.
> 
> You can't do "I can grab reference at any time until the call of
> expkey_pin_kill()" - it's not going to work.  You _must_ grab it
> carefully, being ready to cope with "umount has already decided it's
> not busy, so it's a goner and we must fail" kind of situations.
> 
> You need to
> 	grab mount_lock with read_seqlock_excl()
> 	check that vfsmount isn't marked MNT_SYNC_UMOUNT or MNT_DOOMED
> and bump refcount in such case; give up on attempt otherwise.
> 	drop mount_lock
> for those attempts to grab the first reference.  And be ready to cope with
> failures.
>

Thanks for your comments,

I have do the work in the new version of 6, also I think I have solve the race
between umount and reference to cache again.

thanks
Kinglong Mee
