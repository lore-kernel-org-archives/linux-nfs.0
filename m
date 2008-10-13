From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 11/12] svcrdma: Add a message log string to indicate if
 FastReg is being used
Date: Sun, 12 Oct 2008 21:20:04 -0500
Message-ID: <48F2B054.9040605@opengridcomputing.com>
References: <1223069629-5267-7-git-send-email-tom@opengridcomputing.com> <1223069629-5267-8-git-send-email-tom@opengridcomputing.com> <1223069629-5267-9-git-send-email-tom@opengridcomputing.com> <1223069629-5267-10-git-send-email-tom@opengridcomputing.com> <1223069629-5267-11-git-send-email-tom@opengridcomputing.com> <1223069629-5267-12-git-send-email-tom@opengridcomputing.com> <20081008224840.GF14527@fieldses.org> <48EDA691.9080108@opengridcomputing.com> <20081009162623.GD28785@fieldses.org> <48EE5193.2090702@opengridcomputing.com> <20081010210245.GF19415@fieldses.org> <48F2AFDA.8000704@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:17678 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbYJMCUF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Oct 2008 22:20:05 -0400
In-Reply-To: <48F2AFDA.8000704@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Tucker wrote:
> J. Bruce Fields wrote:
>> On Thu, Oct 09, 2008 at 01:46:43PM -0500, Tom Tucker wrote:
>>  
>>> Coming up with a name for the command is probably
>>> harder than writing it.
>>>
>>> Here it is...
>>>     
>>
>> Neat-o, thanks.
>>
>> Just for fun, I installed libibverbs from Fedora 9, modprobe'd
>> ib_uverbs, and tried running this, and got a "libibverbs: Warning:
>> couldn't open config directory '/etc/libibverbs.d'."  Is there a HOWTO
>> somewhere that I should know about?
>>   
> Hmm. Sounds like the Fedora RPM didn't do all the necessary bits. I 
> have a Fedora 9 system,
> I'll see what I get. I typically use the latest OFED distro.
>

I should qualify this. I use the OFED distro for the user-mode bits. For 
kernel bits, I use top of
tree.

Thanks,
Tom

> Tom
>> --b.
>>
>>  
>>> #include <stdlib.h>
>>> #include <stdio.h>
>>> #include <infiniband/verbs.h>
>>>
>>> #define FAST_REG (1<<21) /* This will be in infiniband/verbs.h in 
>>> the future */
>>>
>>> static char *safety_string(struct ibv_device_attr *a, struct 
>>> ibv_device *dev)
>>> {
>>>         if (a->device_cap_flags & FAST_REG
>>>             || dev->transport_type == IBV_TRANSPORT_IB)
>>>                 return "Safe. NFSRDMA exposes only RPC memory.\n";
>>>         else
>>>                 return "Unsafe. NFSRDMA exposes Server memory.\n";
>>> }
>>>
>>> int main(int argc, char *argv[])
>>> {
>>>         struct ibv_device **dev_list;
>>>         struct ibv_context *context;
>>>         struct ibv_device_attr attr;
>>>         int dev_count;
>>>         int i;
>>>
>>>         dev_list = ibv_get_device_list(&dev_count);
>>>         for (i = 0; dev_list && i < dev_count; i++) {
>>>                 printf("%-20s: ", ibv_get_device_name(dev_list[i]));
>>>                 context = ibv_open_device(dev_list[i]);
>>>                 if (!context) {
>>>                         printf("could not open device\n");
>>>                         continue;
>>>                 }
>>>                 if (!ibv_query_device(context, &attr))
>>>                         printf("%s\n", safety_string(&attr, 
>>> dev_list[i]));
>>>                 else
>>>                         printf("could not query device\n");
>>>
>>>                 ibv_close_device(context);
>>>         }
>>>         if (dev_list)
>>>                 ibv_free_device_list(dev_list);
>>>
>>>         exit(0);
>>> }
>>>
>>>    
>>>> The one drawback is that it wouldn't be able to tell whether the
>>>> currently running kernel actually supported fast registration.  Do you
>>>> think a guess based on kernel version would be good enough for that?
>>>>
>>>>       
>>> I do, yes.
>>>
>>>    
>>>>> This code makes devices more secure than they used to be. So there 
>>>>> is no  negative security regression here. This patchset simply 
>>>>> improves the security for newer devices that support the new 
>>>>> features.
>>>>>         
>>>> Yes, agreed.  Just to be clear, I *have* queued up all but these last
>>>> two patches (the printk and documentation patches) for 2.6.28. 
>>>>       
>>> Ok, thanks.
>>>
>>>    
>>>> --b.
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe 
>>>> linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>       
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>   
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

