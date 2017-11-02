Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26810 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdKBRJS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Nov 2017 13:09:18 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [Nfs-ganesha-devel] NFSv4 referrals not working with ganesha.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAD8zhTAkOavaL3ipW0EHZd1D2acK6mkwP0O3VKjTU4ZT56J5cw@mail.gmail.com>
Date: Thu, 2 Nov 2017 13:08:55 -0400
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>,
        ssaurabh.wisc@gmail.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <00F8AF82-00B8-4A1E-89B3-848A2C4C83FC@oracle.com>
References: <CAD8zhTBggSc34-jFPO9TM8w9DOGiKOZLJVo6-mTYXhU00dxuBg@mail.gmail.com> <001f01d351b3$21b51df0$651f59d0$@mindspring.com> <CAD8zhTDTVemPqJy7-msciEe0Vc475w3h91G8qA1CJsZkDSysNQ@mail.gmail.com> <003501d351cd$d99013c0$8cb03b40$@mindspring.com> <CAD8zhTARmq4PWm4-MvSPnW33g7d7To6EQys-Ewpg5uUjSAQUiA@mail.gmail.com> <CAD8zhTDK-x+UmHnqvKm+5hnoYmob+rOGW1XxFt37-JsDm-Px2w@mail.gmail.com> <CAD8zhTAAvTKhp6k0vYRMnhZW5pxjstpBiDKLgoXocfpAXNjKTg@mail.gmail.com> <5CF06ED5-8A8B-44C1-9D4F-4AEED462FC45@oracle.com> <CAD8zhTAkOavaL3ipW0EHZd1D2acK6mkwP0O3VKjTU4ZT56J5cw@mail.gmail.com>
To: Pradeep <pradeepthomas@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 1, 2017, at 7:25 PM, Pradeep <pradeepthomas@gmail.com> wrote:
> 
> On Wed, Nov 1, 2017 at 8:49 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> On Nov 1, 2017, at 10:53 AM, Pradeep <pradeepthomas@gmail.com> wrote:
>>> 
>>> Adding linux-nfs (did not work last couple of times because of email format).
>>> 
>>> Is this supposed to work with Linux NFS clients (see the problem
>>> description at the end of this email)?
>> 
>> Yes. I've used referrals successfully with upstream kernels in the
>> past week (against non-Linux servers, even).
>> 
>> Looks like this is a RHEL issue, though. Should you report the
>> issue to Red Hat?
>> 
> 
> You can easily reproduce this on Ubuntu 16.04 as well (we have tried
> up to 4.9.37).
> 
>> 
>>> The NFSv4 referrals with Linux clients does not work with 'stat', 'ls'
>>> etc., But linux client follows referrals after a 'cd'. Is this the
>>> expected behavior?
>> 
>> I think so. "ls -l" in the parent directory isn't going to trigger
>> a mount, but "cd" will. After the mount, the mounted on directory
>> on the client will appear as expected with "ls -l".
>> 
> 
> 'ls -l' will show incorrect stats if referral is not followed. Client
> doesn't seem to
> use attributes from READDIR (or it throws away that).
> 
> stat shows output like this for referral directories - you can see
> from tcpdump that server(nfs-ganesha) sent the attributes correctly.
> 
> $ stat /mnt/dir.0
>  File: ‘/mnt/dir.0’
>  Size: 0               Blocks: 0          IO Block: 1048576 directory
> Device: 26h/38d Inode: 1085        Links: 2
> Access: (0555/dr-xr-xr-x)  Uid: (4294967294/ UNKNOWN)   Gid:
> (4294967294/ UNKNOWN)
> Context: system_u:object_r:nfs_t:s0
> Access: 1969-12-31 16:00:00.000000000 -0800
> Modify: 1969-12-31 16:00:00.000000000 -0800
> Change: 1969-12-31 16:00:00.000000000 -0800
> Birth: -
> 
>> 
>>> tcpdump is attached.
>> 
>> Traffic to the destination server might be going over a different
>> network interface. Check your tcpdump command line.
>> 
> 
> I have only one network interface.
> 
>> You could also enable NFS and/or RPC debugging (before reproducing)
>> to see the steps taken by the client displayed in /var/log/messages.
>> 
>> # rpcdebug -m nfs -s
>> # rpcdebug -m rpc -s
>> 
> 
> debug messages from /var/log/messages is attached (see readdir.log and
> stat.log).
> The 'ls -l' output is below. 'dir.0' is the referral directory.
> 
> $ ls -l /mnt
> total 0
> dr-xr-xr-x. 2 4294967294 4294967294 0 Dec 31  1969 dir.0
> drwxrwxr-x. 2 pradeep    pradeep    6 Oct 16 17:07 dir.1
> drwxrwxr-x. 2 pradeep    pradeep    6 Oct 16 17:07 dir.2
> 
> The problem appears to be in the code path below:
> 
> nfs4_proc_lookup_common -> _nfs4_proc_lookup -> nfs4_get_referral ->
> nfs_fixup_referral_attributes
> 
>        /* Fixup attributes for the nfs_lookup() call to nfs_fhget() */
>        nfs_fixup_referral_attributes(&locations->fattr);
> 
>       /* replace the lookup nfs_fattr with the locations nfs_fattr */
>        memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
> 
> 'fattr' will never have attributes other than FSID and fs_locations.

Sorry, it wasn't clear to me before what problem you were reporting.

We've established that the destination server will not be contacted
if you do just an "ls -l" in the parent directory.

commit 6b97fd3da1eab2cc490cfe884c7d4956522eaf8b
Author:     Manoj Naik <manoj@almaden.ibm.com>
AuthorDate: Fri Jun 9 09:34:29 2006 -0400
Commit:     Trond Myklebust <Trond.Myklebust@netapp.com>
CommitDate: Fri Jun 9 09:34:29 2006 -0400

    NFSv4: Follow a referral
    
    Respond to a moved error on NFS lookup by setting up the referral.
    Note: We don't actually follow the referral during lookup/getattr, but
    later when we detect fsid mismatch in inode revalidation (similar to the
    processing done for cloning submounts). Referrals will have fake attributes
    until they are actually followed or traversed.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


So, before the referral mount, you want to see sane attributes
instead of:

> dr-xr-xr-x. 2 4294967294 4294967294 0 Dec 31  1969 dir.0


?

This is the usual behavior, although a bit ugly and unhelpful.

[root@manet mnt]# ls -l
total 3
drwxr-xr-x 14 cel        users      14 Aug 10  2016 clients
drwxr-xr-x  2 cel        users       2 Oct 19 11:32 manet.1015granger.net
dr-xr-xr-x  2 4294967294 4294967294  0 Dec 31  1969 referral1
dr-xr-xr-x  2 4294967294 4294967294  0 Dec 31  1969 referral2
[root@manet mnt]# uname -a
Linux manet.1015granger.net 4.14.0-rc4-00055-g16244f1 #358 SMP Thu Nov 2 12:04:32 EDT 2017 x86_64 x86_64 x86_64 GNU/Linux
[root@manet mnt]#


I suppose what we'd rather see at this point is the attributes
of the referral object, not the destination directory. I'm not
yet sure how that memcpy needs to work. This code is invoked
in other cases too.


>>>>> On Mon, Oct 30, 2017 at 3:24 PM, Frank Filz <ffilzlnx@mindspring.com>
>>>>> wrote:
>>>>>> 
>>>>>> Oh, I had forgotten about that patch…
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Can you try any other clients? This may be a client issue (I did see some
>>>>>> suspicious code in the client).
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> It may also be that you need a fully qualified path (starting with a /).
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> It looks like Ganesha is doing the right thing though.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Frank
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> From: Pradeep [mailto:pradeep.thomas@gmail.com]
>>>>>> Sent: Monday, October 30, 2017 2:21 PM
>>>>>> To: Frank Filz <ffilzlnx@mindspring.com>
>>>>>> Cc: nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>;
>>>>>> ssaurabh.wisc@gmail.com
>>>>>> Subject: Re: [Nfs-ganesha-devel] NFSv4 referrals not working with
>>>>>> ganesha.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Hi Frank,
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> This is with latest version of Ganesha. The referral support is already
>>>>>> in VFS: https://review.gerrithub.io/c/353684
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> tcpdump is attached. From the tcpdump, we can see that the stat sent a
>>>>>> LOOKUP for the remote export and received a moved error. It also sent back
>>>>>> the fs_locations. But the client (CentOS 7.3) never followed that with a
>>>>>> LOOKUP to the remote server.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> You can see that packet #41 has the correct FS locations. But client does
>>>>>> not do another lookup to get the correct attributes.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> $ stat /mnt/nfs_d1
>>>>>> 
>>>>>> File: ‘/mnt/nfs_d1’
>>>>>> 
>>>>>> Size: 0               Blocks: 0          IO Block: 1048576 directory
>>>>>> 
>>>>>> Device: 28h/40d Inode: 1           Links: 2
>>>>>> 
>>>>>> Access: (0555/dr-xr-xr-x)  Uid: (4294967294/ UNKNOWN)   Gid: (4294967294/
>>>>>> UNKNOWN)
>>>>>> 
>>>>>> Context: system_u:object_r:nfs_t:s0
>>>>>> 
>>>>>> Access: 1969-12-31 16:00:00.000000000 -0800
>>>>>> 
>>>>>> Modify: 1969-12-31 16:00:00.000000000 -0800
>>>>>> 
>>>>>> Change: 1969-12-31 16:00:00.000000000 -0800
>>>>>> 
>>>>>> Birth: -
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> On Mon, Oct 30, 2017 at 12:13 PM, Frank Filz <ffilzlnx@mindspring.com>
>>>>>> wrote:
>>>>>> 
>>>>>> What version of Ganesha? I assume by “native” FSAL, you mean FSAL_VFS?
>>>>>> Did you add the fs locations XATTR support? FSAL_GPFS currently has the only
>>>>>> in-tree referral support and I’m not sure it necessarily works, but I’m
>>>>>> unable to test it.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> If you have code for FSAL_VFS to add the fs locations attribute, go ahead
>>>>>> and post it and I could poke at it.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Also, tcpdump traces might help understand what is going wrong.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Frank
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> From: Pradeep [mailto:pradeep.thomas@gmail.com]
>>>>>> Sent: Monday, October 30, 2017 11:45 AM
>>>>>> To: nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>
>>>>>> Cc: ssaurabh.wisc@gmail.com
>>>>>> Subject: [Nfs-ganesha-devel] NFSv4 referrals not working with ganesha.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Hi all,
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> We are testing NFSv4 referral for Linux CentOS 7 with nfs-ganesha and are
>>>>>> running
>>>>>> 
>>>>>> into some serious issues.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Although, we were able to set up NFSv4 referral using the native Ganesha
>>>>>> FSAL,
>>>>>> 
>>>>>> we could not get it fully functional for all Linux client system calls.
>>>>>> 
>>>>>> Basically, the NFSv4 spec suggests to return a NFS4ERR_MOVED on a
>>>>>> 
>>>>>> LOOKUP done for a remote export. However, this breaks the `stat` system
>>>>>> call on
>>>>>> 
>>>>>> Linux CentOS 7 (stat’ results in a LOOKUP,GETFH,GETATTR compound). An
>>>>>> easy way to
>>>>>> 
>>>>>> reproduce the broken behavior is:
>>>>>> 
>>>>>> 1) mount the root of the pseudo file system and
>>>>>> 
>>>>>> 2) issue a `stat` command on the remote export.
>>>>>> 
>>>>>> The stat returned are corrupt.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> After digging into the CentOS 7 client code, we realized that the stat
>>>>>> operation
>>>>>> 
>>>>>> is never expected to follow the referral. However, switching to returning
>>>>>> NFS4_OK
>>>>>> 
>>>>>> for stat, then breaks `cd` or a `ls -l` command, because now we don't
>>>>>> know when
>>>>>> 
>>>>>> to follow the referral.
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Does anyone have a successful experience in setting up the NFSv4
>>>>>> referrals that
>>>>>> 
>>>>>> they could share? Or, if some suggestions on what we might be doing
>>>>>> wrong?
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Thanks
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Virus-free. www.avast.com
>>>>>> 
>>>>>> 
>>>>> 
>>>>> 
>>>> 
>>> <nfs_remote_export1.pcap>
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
> <readdir.log><stat.log>

--
Chuck Lever



