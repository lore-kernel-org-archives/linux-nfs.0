Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37362 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030354Ab2AFPvN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 10:51:13 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "<tigran.mkrtchyan@desy.de>" <tigran.mkrtchyan@desy.de>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Subject: Re: server reboot recovery is broken with 3.1 (3.2?) with nfsv41
 clients
Date: Fri, 6 Jan 2012 15:50:42 +0000
Message-ID: <27ECC95F-A1B6-43A8-AC1C-F01D680F50D7@netapp.com>
References: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
 <081C1E0B-795E-4138-B66A-479F73BB3AC5@netapp.com>
 <CAGue13pFCq22xUmJny7+7czc8WkPhjos2A+_BombOf3G8icwJA@mail.gmail.com>
 <CAGue13r+vZRkmpiHVPodyoYXt+SVCfDdgHJOF74TmL5=ci=q1w@mail.gmail.com>
 <F19688880B763E40B28B2B462677FBF805E3A4A802@MX09A.corp.emc.com>
 <CAGue13q8RbFmqWzz4BkL_hAfiFayM79MZUrL8nx=4SZDWy7tpQ@mail.gmail.com>
 <CAGue13qS1y69BuOXgnFoYPmKDJRMWiXnkLvXqN5cP0qro+MU7A@mail.gmail.com>
In-Reply-To: <CAGue13qS1y69BuOXgnFoYPmKDJRMWiXnkLvXqN5cP0qro+MU7A@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran

Sorry - I dropped the ball on this one.  I'll try reproducing it now.

-->Andy

On Jan 6, 2012, at 10:39 AM, Tigran Mkrtchyan wrote:

> FYI,
> 
> this is still the case with 3.2
> 
> Tigran.
> 
> On Tue, Nov 22, 2011 at 1:07 PM, Tigran Mkrtchyan
> <tigran.mkrtchyan@desy.de> wrote:
>> as usually....
>> 
>> TIgran.
>> 
>> 
>> On Tue, Nov 22, 2011 at 3:07 AM,  <tao.peng@emc.com> wrote:
>>>> -----Original Message-----
>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Tigran
>>>> Mkrtchyan
>>>> Sent: Monday, November 21, 2011 5:52 PM
>>>> To: Adamson, Andy
>>>> Cc: linux-nfs
>>>> Subject: Re: server reboot recovery is broken with 3.1 (3.2?) with nfsv41 clients
>>>> 
>>>> RHEL6.2 has the same issue. I just rebooted server (mds + ds) during read.
>>>> 
>>>> Kernel thread dump attached.
>>> Forgot attachment? :)
>>> 
>>>> 
>>>> Tigran.
>>>> 
>>>> On Fri, Nov 18, 2011 at 5:09 PM, Tigran Mkrtchyan
>>>> <tigran.mkrtchyan@desy.de> wrote:
>>>>> Both!
>>>>> 
>>>>> On Fri, Nov 18, 2011 at 3:08 PM, Adamson, Andy
>>>>> <William.Adamson@netapp.com> wrote:
>>>>>> 
>>>>>> On Nov 18, 2011, at 8:57 AM, Tigran Mkrtchyan wrote:
>>>>>> 
>>>>>>> Dear  nfs hackers,
>>>>>>> 
>>>>>>> it looks like with kernel 3.1 client cant recover from server reboots.
>>>>>>> The nfs mount hangs and there are no packages sent from a client to the server.
>>>>>>> This was IO with pnfs.
>>>>>> 
>>>>>> 
>>>>>> Hi Tigran
>>>>>> 
>>>>>> Is this an MDS reboot? DS reboot?
>>>>>> 
>>>>>> Thanks
>>>>>> 
>>>>>> -->Andy
>>>>>>> 
>>>>>>> Regards,
>>>>>>>   Tigran.
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> 
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> 
>>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> 

