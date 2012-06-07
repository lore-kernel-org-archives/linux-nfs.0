Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:49981 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755725Ab2FGKgv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 06:36:51 -0400
Received: by weyu7 with SMTP id u7so256799wey.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jun 2012 03:36:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD07F7D.6070509@panasas.com>
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
	<4FD06290.7050004@panasas.com>
	<CAKYAXd8rwY-mHiO+5691qq5w=O-Gs1FXQ4CjEbPDLVnPSkkBTQ@mail.gmail.com>
	<4FD07F7D.6070509@panasas.com>
Date: Thu, 7 Jun 2012 19:36:50 +0900
Message-ID: <CAKYAXd8YCoX3jYK5=gNE3jKyvqTQpawpMkhMKWToCpsTLkcJew@mail.gmail.com>
Subject: =?UTF-8?Q?Re=3A_=5BProblem=5DNFS_Server_=E2=80=93_Umount_results_in_Device?=
	=?UTF-8?Q?_Busy=2E?=
From: Namjae Jeon <linkinjeon@gmail.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/6/7, Boaz Harrosh <bharrosh@panasas.com>:
> On 06/07/2012 12:43 PM, Namjae Jeon wrote:
>
>> 2012/6/7, Boaz Harrosh <bharrosh@panasas.com>:
>>> On 06/07/2012 10:47 AM, Namjae Jeon wrote:
>>>
>>>> Hi Bruce, Trond.
>>>>
>>>> As you know, Currently umount results in busy on NFS server although
>>>> user tried to succeed to umount on NFS client.
>>>> I suggest to add umount procedure to avoid umount busy issue.
>>>> When calling umount on NFS client, The resources(exportfs entries
>>>> cache) of mount point will be flushed on NFS server. and umount will
>>>> be succeed without busy issue.
>>>>
>>>> how do you think about this suggestion ?
>>>>
>>>
>>>
>>> I second this request, what is needed so when all clients unmounted,
>>> the system comes back to the sate it was before any clients have
>>> mounted. i.e filesystems is not referenced and may unmount cleanly.
>>> (This also happens with >= 4.0 clients only, so no excuses)
>>>
>>> This is a real problem for me, on Fedora machines. Because I export
>>> iscsi devices which are network devices, and in the shutdown procedure
>>> for some reason the "service nfs stop" of the server is much much to
>>> late. the original umount of exofs (-o _netdev) fails because it's
>>> held by NFSD, the iscsi devices go away regardless, and when nfsd
>>> finally releases exofs, it gets deadlocked on some error handling.
>>> OK I know I must fix the stuck-ness, but the problem will remain.
>>> The FS will not unmount cleanly because it will only attempt
>>> an unmount after its devices are gone. This will be solved if
>>> nfsd would release its hold on the FS when all clients are gone.
>>>
>>> It was on my TODO to fix this for a long time, but I seem to be
>>> too busy with more urgent matters. (What's the point of fixing the
>>> shutdown if the steady state doesn't work yet)
>>>
>>> If someone has investigated the matter and knows what to do I would
>>> appreciate any insights, and/or patches would be wonderful ;-)
>> Hi Boaz.
>> Oh.. You also are facing same problem.
>> Actually I almost finish to imprement the patch about umount busy
>> issue on NFS server. But I want to know Maintainer's opinion before
>> posting.
>> Thanks.
>
>
> Please post it (maybe as RFC) I want to see it
Okay, I will soon.
>
> Thanks
> Boaz
>
>>>
>>>> Thanks.
>>>>
>>>
>>> <>
>>>
>>> Thanks
>>> Boaz
>>>
>>>
>
>
>
