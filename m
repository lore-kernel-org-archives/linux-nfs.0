Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161Ab2BHQes (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 11:34:48 -0500
Message-ID: <4F32A424.20907@RedHat.com>
Date: Wed, 08 Feb 2012 11:34:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: James Morris <jmorris@namei.org>
CC: Linux Keyring Mailing list <keyrings@linux-nfs.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Make keys writable on the idmap keyring.
References: <1328619733-30859-1-git-send-email-steved@redhat.com> <alpine.LRH.2.02.1202081029000.777@tundra.namei.org>
In-Reply-To: <alpine.LRH.2.02.1202081029000.777@tundra.namei.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm indifferent... as long as it gets in...

Personally I thought it should been be part of David's 
"KEYS: Allow special keyrings to be cleared" patch
since NFS can not use that feature unless the
key is writable... 

steved.

On 02/07/2012 06:29 PM, James Morris wrote:
> Should this go in via the NFS tree?  I can put it into the security tree 
> otherwise.
> 
> 
> On Tue, 7 Feb 2012, Steve Dickson wrote:
> 
>> To take advantage of the "Allow special keyrings to be
>> cleared" keyring patch the NFS keyring has to be writeable.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  fs/nfs/idmap.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>> index a1bbf77..1d88cdb 100644
>> --- a/fs/nfs/idmap.c
>> +++ b/fs/nfs/idmap.c
>> @@ -269,7 +269,7 @@ static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
>>  	}
>>  
>>  	rcu_read_lock();
>> -	rkey->perm |= KEY_USR_VIEW;
>> +	rkey->perm |= KEY_USR_VIEW|KEY_USR_WRITE;
>>  
>>  	ret = key_validate(rkey);
>>  	if (ret < 0)
>> -- 
>> 1.7.7.5
>>
> 
