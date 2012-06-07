Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47776 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab2FGXl0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 19:41:26 -0400
Received: by eeit10 with SMTP id t10so607926eei.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jun 2012 16:41:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120607113358.GB8684@fieldses.org>
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
	<4FD06290.7050004@panasas.com>
	<20120607113358.GB8684@fieldses.org>
Date: Fri, 8 Jun 2012 08:41:25 +0900
Message-ID: <CAKYAXd8C7f6jBiU5HF8oyL0w0rfdg6WfqRpu_aSEgN1XOfpS_g@mail.gmail.com>
Subject: =?UTF-8?Q?Re=3A_=5BProblem=5DNFS_Server_=E2=80=93_Umount_results_in_Device?=
	=?UTF-8?Q?_Busy=2E?=
From: Namjae Jeon <linkinjeon@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/6/7, J. Bruce Fields <bfields@fieldses.org>:
> On Thu, Jun 07, 2012 at 11:13:04AM +0300, Boaz Harrosh wrote:
>> On 06/07/2012 10:47 AM, Namjae Jeon wrote:
>> > As you know, Currently umount results in busy on NFS server although
>> > user tried to succeed to umount on NFS client.
>> > I suggest to add umount procedure to avoid umount busy issue.
>> > When calling umount on NFS client, The resources(exportfs entries
>> > cache) of mount point will be flushed on NFS server. and umount will
>> > be succeed without busy issue.
>> >
>> > how do you think about this suggestion ?
>
> I'm not sure how adding an "unmount" rpc to the protocol would really
> help here, if that's what you're asking for.

Since, at the NFS server it is just a normal device which is mounted.
So, After NFS client operation is over and it has successfully
unmounted. Then at the Server side the umount should be transparent.
As suppose if the user does
umount /mnt -> he might not have knowlege that is NFS mounted and
could think this to be issue.
  So - if we should have a transparent mechanism for umount at NFS server also
  NFS Server
mount /dev/sda1 /mnt
NFs Client :
mount -t nfs <IP>: /mnt /mnt
umount /mnt
After this if a user wants to disconnect USB device - there should be no problem

>
> If you're just looking for a command you could run on the server after
> all the clients have unmounted--"exportfs -f" or "service stop nfsd" (or
> equivalent) should do the job.
>
>> I second this request, what is needed so when all clients unmounted,
>> the system comes back to the sate it was before any clients have
>> mounted. i.e filesystems is not referenced and may unmount cleanly.
>> (This also happens with >= 4.0 clients only, so no excuses)
>>
>> This is a real problem for me, on Fedora machines. Because I export
>> iscsi devices which are network devices, and in the shutdown procedure
>> for some reason the "service nfs stop" of the server is much much to
>> late.
>
> Sounds like a bug in the Fedora systemd configuration?
>
>> the original umount of exofs (-o _netdev) fails because it's
>> held by NFSD, the iscsi devices go away regardless, and when nfsd
>> finally releases exofs, it gets deadlocked on some error handling.
>> OK I know I must fix the stuck-ness, but the problem will remain.
>> The FS will not unmount cleanly because it will only attempt
>> an unmount after its devices are gone. This will be solved if
>> nfsd would release its hold on the FS when all clients are gone.
>
> Note nfsd doesn't really know when that is.  Even with NFSv4, processes
> can be using the filesystem without holding state on the server: they
> might just have a current working directory in the filesystem, or have a
> device special file open.
>
>> It was on my TODO to fix this for a long time, but I seem to be
>> too busy with more urgent matters. (What's the point of fixing the
>> shutdown if the steady state doesn't work yet)
>>
>> If someone has investigated the matter and knows what to do I would
>> appreciate any insights, and/or patches would be wonderful ;-)
>
> My first concern would be to fix any ordering bugs in the systemd
> configuration, or any reference count leaks.
>
> --b.
>
