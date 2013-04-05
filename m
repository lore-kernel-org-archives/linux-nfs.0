Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g1t0028.austin.hp.com ([15.216.28.35]:39307 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162753Ab3DEU0n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 16:26:43 -0400
Message-ID: <515F3373.40302@hp.com>
Date: Fri, 05 Apr 2013 16:26:27 -0400
From: Waiman Long <Waiman.Long@hp.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <mszeredi@suse.cz>,
        Ian Kent <raven@themaw.net>, Sage Weil <sage@inktank.com>,
        Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 1/4] dcache: Don't take unnecessary lock in d_count
 update
References: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com> <1365181061-30787-2-git-send-email-Waiman.Long@hp.com> <20130405171220.GD4068@ZenIV.linux.org.uk>
In-Reply-To: <20130405171220.GD4068@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/05/2013 01:12 PM, Al Viro wrote:
>> @@ -635,22 +640,14 @@ struct dentry *dget_parent(struct dentry *dentry)
>>   {
>>   	struct dentry *ret;
>>
>> -repeat:
>> -	/*
>> -	 * Don't need rcu_dereference because we re-check it was correct under
>> -	 * the lock.
>> -	 */
>>   	rcu_read_lock();
>> -	ret = dentry->d_parent;
>> -	spin_lock(&ret->d_lock);
>> -	if (unlikely(ret != dentry->d_parent)) {
>> -		spin_unlock(&ret->d_lock);
>> -		rcu_read_unlock();
>> -		goto repeat;
>> -	}
>> +	ret = rcu_dereference(dentry->d_parent);
>>   	rcu_read_unlock();
>> +	if (dcount_inc_cmpxchg(ret))
>> +		return ret;
>> +	spin_lock(&ret->d_lock);
> And WTF is going to protect your "ret" from being freed just as you'd done
> rcu_read_unlock()?

I think I had made a mistake here. I should move the rcu_read_unlock() 
down to before the return statement as well as after the spin_lock(). 
Thank for pointing this out. I will fix that in the next version. 
Anything else that needs to be fixed?

Regards,
Longman
