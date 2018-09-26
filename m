Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725806AbeI0AYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Sep 2018 20:24:02 -0400
Subject: Re: [PATCH] nfs-utils mount: recover the lost EBUSY
To: Jianhong Yin <jiyin@redhat.com>
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
References: <20180917113838.31952-1-jiyin@redhat.com>
 <a9f8b089-b701-f9cd-5ec0-9afa02997c6f@RedHat.com>
 <1823792730.16120317.1537928486853.JavaMail.zimbra@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d5fffd93-e6f6-ddfa-2738-6c41934e9b58@RedHat.com>
Date: Wed, 26 Sep 2018 14:09:53 -0400
MIME-Version: 1.0
In-Reply-To: <1823792730.16120317.1537928486853.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 9/25/18 10:21 PM, Jianhong Yin wrote:
> 
> ----- 原始邮件 -----
>> 发件人: "Steve Dickson" <SteveD@RedHat.com>
>> 收件人: jiyin@redhat.com
>> 抄送: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
>> 发送时间: 星期二, 2018年 9 月 25日 下午 11:40:03
>> 主题: Re: [PATCH] nfs-utils mount: recover the lost EBUSY
>>
>>
>>
>> On 9/17/18 7:38 AM, jiyin@redhat.com wrote:
>>> From: "Jianhong.Yin" <yin-jianhong@163.com>
>>>
>>> see: https://bugzilla.redhat.com/show_bug.cgi?id=1629705
>>> [nfs-utils] mount -osharecache failure but return 'true'
>>>
>>> mount.nfs4 -o context=system_u:object_r:user_home_dir_t:s0,sharecache
>>> $serv:$expdir $nfsmp
>>> mount.nfs4 -o context=system_u:object_r:xferlog_t:s0,sharecache
>>> $serv:$expdir $nfsmp2
>>> ^^^ here mount fail, but return true. it confuse user!
>>>
>>> Anyway, we should not hide the failure and pretend that it
>>> does not exist.
>>>
>>> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
>>> ---
>>>  utils/mount/stropts.c | 9 ---------
>>>  1 file changed, 9 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 4d2e37e..ca5bc7f 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -1078,15 +1078,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>>>  		if (nfs_try_mount(mi))
>>>  			return EX_SUCCESS;
>>>  
>>> -		if (errno == EBUSY)
>>> -			/* The only cause of EBUSY is if exactly the desired
>>> -			 * filesystem is already mounted.  That can arguably
>>> -			 * be seen as success.  "mount -a" tries to optimise
>>> -			 * out this case but sometimes fails.  Help it out
>>> -			 * by pretending everything is rosy
>>> -			 */
>>> -			return EX_SUCCESS;
>>> -
>>>  		if (nfs_is_permanent_error(errno))
>>>  			break;
>>>  
>>>
>> It code is here because of commit 3904d8102 which argues
>> the re-mounting of a filesystem that is already mounted
>> is not an error... which I tend to agree with...
> Got it.
> 
> how about : change in kernel  if (re-mounting && busy)  return TRUE from syscall->mount
Propose on to see where it goes... 

steved.

> 
>>
>> steved.
>>
