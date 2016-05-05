Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757377AbcEEQxt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2016 12:53:49 -0400
Subject: Re: [PATCH 2/2] gssd: move read of upcall into main thread
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
References: <1462286792-8889-1-git-send-email-kolga@netapp.com>
 <1462286792-8889-2-git-send-email-kolga@netapp.com>
 <50edf6a8-4d4c-07d5-af0a-363ac66dbfa5@RedHat.com>
 <AD00DA1B-EBAD-4DD8-B50F-F9378FBA1822@netapp.com>
 <574d004f-4b42-d4aa-60f6-607ffae6dd1b@RedHat.com>
 <A0B61D59-F17E-4FE4-8A51-537AA7939939@netapp.com>
 <FC32683A-F74A-4FB9-834F-ECBBBBD099D5@netapp.com>
 <222b4f6c-6f7a-2951-6d4e-75a522cde905@RedHat.com>
 <2D606FA4-2777-48B6-979C-C27F4BADA43A@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <ce76fe3e-2c19-eed8-0b1c-a8f8f9157e18@RedHat.com>
Date: Thu, 5 May 2016 12:53:47 -0400
MIME-Version: 1.0
In-Reply-To: <2D606FA4-2777-48B6-979C-C27F4BADA43A@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/05/2016 12:43 PM, Kornievskaia, Olga wrote:
> 
>> On May 5, 2016, at 12:40 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>>
>> On 05/05/2016 11:40 AM, Kornievskaia, Olga wrote:
>>>
>>>> On May 5, 2016, at 11:35 AM, Kornievskaia, Olga <Olga.Kornievskaia@netapp.com <mailto:Olga.Kornievskaia@netapp.com>> wrote:
>>>>
>>>>>
>>>>> On May 5, 2016, at 10:17 AM, Steve Dickson <SteveD@redhat.com <mailto:SteveD@redhat.com>> wrote:
>>>>>
>>>>> Hello,
>>>>>
>>>>> On 05/04/2016 10:15 AM, Kornievskaia, Olga wrote:
>>>>>> I’m having a hard time picturing what you have in mind. I don’t see how you can allocate, 
>>>>>> populate and free in one routine. The logic is we allocate memory, then read the upcall 
>>>>>> and only then we create the thread. If either upcall or creation of the thread 
>>>>>> fails we need to free the allocated memory.
>>>>> Something like this:
>>>>>
>>>>> gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void *data)
>>>>> {
>>>>>      struct clnt_info *clp = data;
>>>>> -       pthread_t th;
>>>>> -       int ret;
>>>>> +       struct clnt_upcall_info *info;
>>>>>
>>>>> -       ret = pthread_create(&th, NULL, (void *)handle_gssd_upcall,
>>>>> -                               (void *)clp);
>>>>> -       if (ret != 0) {
>>>>> -               printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
>>>>> -                        ret, strerror(errno));
>>>>> +       info = alloc_upcall_info(clp);
>>>>> +       if (info == NULL)
>>>>> +               return;
>>>>> +
>>>>> +       info->lbuflen = read(clp->gssd_fd, info->lbuf, sizeof(info->lbuf));
>>>>> +       if (info->lbuflen <= 0 || info->lbuf[info->lbuflen-1] != '\n') {
>>>>> +               printerr(0, "WARNING: %s: failed reading request\n", __func__);
>>>>> +               free(info);
>>>>>              return;
>>>>>      }
>>>>> -       wait_for_child_and_detach(th);
>>>>> +       info->lbuf[info->lbuflen-1] = 0;
>>>>> +
>>>>> +       start_upcall_thread(handle_gssd_upcall, info);
>>>>> +
>>>>> +       free(info);
>>>>> +       return;
>>>>
>>>> Gotcha! Sounds good! You can make the modifications. Or just in case since you are traveling, 
>>> I’ll just send another patch. Please also add any other lines like Modified-by or Signed-off-by that are need.
>>>
>>> I’m sorry I spoke too soon. “info” is allocated and given to the thread 
>>> to process so the main thread can’t free it. 
>> I'm curious as to why? The main thread allocated it, is handing allocated memory 
>> to a thread something special? What am I missing?
> 
> The main thread allocates memory, gives it to the the child thread and goes 
> to the next libevent. We detach the thread so if we free the memory in the main 
> thread, the child thread would segfault.
Ah... that is the part I missed... You are right... That's what I
get for not testing... Let's go with the original patch and move on... 

steved.

