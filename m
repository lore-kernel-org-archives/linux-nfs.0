Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36535 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbEHAgT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 20:36:19 -0400
Message-ID: <554C04FB.10802@gmail.com>
Date: Fri, 08 May 2015 08:36:11 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 1/4] fs_pin: Fix uninitialized value in fs_pin
References: <554A149B.5060102@gmail.com> <554A14DB.1020504@gmail.com> <20150507194335.GA16527@fieldses.org>
In-Reply-To: <20150507194335.GA16527@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/8/2015 3:43 AM, J. Bruce Fields wrote:
> On Wed, May 06, 2015 at 09:19:23PM +0800, Kinglong Mee wrote:
>> Without initialized, done in fs_pin at stack space may
>> contains strange value.
> 
> Looks like both init_fs_pin callers use some variation on kzalloc(), so
> I don't think there's any actual bug here.

Yes, you are right.

But nfsd's export cache using kmalloc for memory allocating,
if I insert a fs_pin into svc_export{}, the value of done maybe
strange value.

Maybe I should update using kzalloc in nfsd?
But I'd like this one.

thanks,
Kinglong Mee

> 
> Maybe there's some other reason for the belt-and-suspenders approach,
> that's Al's call, I think.
> 
> --b.
> 
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  include/linux/fs_pin.h | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
>> index 3886b3b..18fad53 100644
>> --- a/include/linux/fs_pin.h
>> +++ b/include/linux/fs_pin.h
>> @@ -16,6 +16,7 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
>>  	INIT_HLIST_NODE(&p->s_list);
>>  	INIT_HLIST_NODE(&p->m_list);
>>  	p->kill = kill;
>> +	p->done = 0;
>>  }
>>  
>>  void pin_remove(struct fs_pin *);
>> -- 
>> 2.4.0
>>
> 
