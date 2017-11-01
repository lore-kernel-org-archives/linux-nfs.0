Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31226 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754701AbdKAPtf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Nov 2017 11:49:35 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [Nfs-ganesha-devel] NFSv4 referrals not working with ganesha.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAD8zhTAAvTKhp6k0vYRMnhZW5pxjstpBiDKLgoXocfpAXNjKTg@mail.gmail.com>
Date: Wed, 1 Nov 2017 11:49:11 -0400
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>,
        ssaurabh.wisc@gmail.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5CF06ED5-8A8B-44C1-9D4F-4AEED462FC45@oracle.com>
References: <CAD8zhTBggSc34-jFPO9TM8w9DOGiKOZLJVo6-mTYXhU00dxuBg@mail.gmail.com> <001f01d351b3$21b51df0$651f59d0$@mindspring.com> <CAD8zhTDTVemPqJy7-msciEe0Vc475w3h91G8qA1CJsZkDSysNQ@mail.gmail.com> <003501d351cd$d99013c0$8cb03b40$@mindspring.com> <CAD8zhTARmq4PWm4-MvSPnW33g7d7To6EQys-Ewpg5uUjSAQUiA@mail.gmail.com> <CAD8zhTDK-x+UmHnqvKm+5hnoYmob+rOGW1XxFt37-JsDm-Px2w@mail.gmail.com> <CAD8zhTAAvTKhp6k0vYRMnhZW5pxjstpBiDKLgoXocfpAXNjKTg@mail.gmail.com>
To: Pradeep <pradeepthomas@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 1, 2017, at 10:53 AM, Pradeep <pradeepthomas@gmail.com> wrote:
> 
> Adding linux-nfs (did not work last couple of times because of email format).
> 
> Is this supposed to work with Linux NFS clients (see the problem
> description at the end of this email)?

Yes. I've used referrals successfully with upstream kernels in the
past week (against non-Linux servers, even).

Looks like this is a RHEL issue, though. Should you report the
issue to Red Hat?


> The NFSv4 referrals with Linux clients does not work with 'stat', 'ls'
> etc., But linux client follows referrals after a 'cd'. Is this the
> expected behavior?

I think so. "ls -l" in the parent directory isn't going to trigger
a mount, but "cd" will. After the mount, the mounted on directory
on the client will appear as expected with "ls -l".


> tcpdump is attached.

Traffic to the destination server might be going over a different
network interface. Check your tcpdump command line.

You could also enable NFS and/or RPC debugging (before reproducing)
to see the steps taken by the client displayed in /var/log/messages.

 # rpcdebug -m nfs -s
 # rpcdebug -m rpc -s


>>> On Mon, Oct 30, 2017 at 3:24 PM, Frank Filz <ffilzlnx@mindspring.com>
>>> wrote:
>>>> 
>>>> Oh, I had forgotten about that patch…
>>>> 
>>>> 
>>>> 
>>>> Can you try any other clients? This may be a client issue (I did see some
>>>> suspicious code in the client).
>>>> 
>>>> 
>>>> 
>>>> It may also be that you need a fully qualified path (starting with a /).
>>>> 
>>>> 
>>>> 
>>>> It looks like Ganesha is doing the right thing though.
>>>> 
>>>> 
>>>> 
>>>> Frank
>>>> 
>>>> 
>>>> 
>>>> From: Pradeep [mailto:pradeep.thomas@gmail.com]
>>>> Sent: Monday, October 30, 2017 2:21 PM
>>>> To: Frank Filz <ffilzlnx@mindspring.com>
>>>> Cc: nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>;
>>>> ssaurabh.wisc@gmail.com
>>>> Subject: Re: [Nfs-ganesha-devel] NFSv4 referrals not working with
>>>> ganesha.
>>>> 
>>>> 
>>>> 
>>>> Hi Frank,
>>>> 
>>>> 
>>>> 
>>>> This is with latest version of Ganesha. The referral support is already
>>>> in VFS: https://review.gerrithub.io/c/353684
>>>> 
>>>> 
>>>> 
>>>> tcpdump is attached. From the tcpdump, we can see that the stat sent a
>>>> LOOKUP for the remote export and received a moved error. It also sent back
>>>> the fs_locations. But the client (CentOS 7.3) never followed that with a
>>>> LOOKUP to the remote server.
>>>> 
>>>> 
>>>> 
>>>> You can see that packet #41 has the correct FS locations. But client does
>>>> not do another lookup to get the correct attributes.
>>>> 
>>>> 
>>>> 
>>>> $ stat /mnt/nfs_d1
>>>> 
>>>>  File: ‘/mnt/nfs_d1’
>>>> 
>>>>  Size: 0               Blocks: 0          IO Block: 1048576 directory
>>>> 
>>>> Device: 28h/40d Inode: 1           Links: 2
>>>> 
>>>> Access: (0555/dr-xr-xr-x)  Uid: (4294967294/ UNKNOWN)   Gid: (4294967294/
>>>> UNKNOWN)
>>>> 
>>>> Context: system_u:object_r:nfs_t:s0
>>>> 
>>>> Access: 1969-12-31 16:00:00.000000000 -0800
>>>> 
>>>> Modify: 1969-12-31 16:00:00.000000000 -0800
>>>> 
>>>> Change: 1969-12-31 16:00:00.000000000 -0800
>>>> 
>>>> Birth: -
>>>> 
>>>> 
>>>> 
>>>> 
>>>> 
>>>> On Mon, Oct 30, 2017 at 12:13 PM, Frank Filz <ffilzlnx@mindspring.com>
>>>> wrote:
>>>> 
>>>> What version of Ganesha? I assume by “native” FSAL, you mean FSAL_VFS?
>>>> Did you add the fs locations XATTR support? FSAL_GPFS currently has the only
>>>> in-tree referral support and I’m not sure it necessarily works, but I’m
>>>> unable to test it.
>>>> 
>>>> 
>>>> 
>>>> If you have code for FSAL_VFS to add the fs locations attribute, go ahead
>>>> and post it and I could poke at it.
>>>> 
>>>> 
>>>> 
>>>> Also, tcpdump traces might help understand what is going wrong.
>>>> 
>>>> 
>>>> 
>>>> Frank
>>>> 
>>>> 
>>>> 
>>>> From: Pradeep [mailto:pradeep.thomas@gmail.com]
>>>> Sent: Monday, October 30, 2017 11:45 AM
>>>> To: nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>
>>>> Cc: ssaurabh.wisc@gmail.com
>>>> Subject: [Nfs-ganesha-devel] NFSv4 referrals not working with ganesha.
>>>> 
>>>> 
>>>> 
>>>> Hi all,
>>>> 
>>>> 
>>>> 
>>>> We are testing NFSv4 referral for Linux CentOS 7 with nfs-ganesha and are
>>>> running
>>>> 
>>>> into some serious issues.
>>>> 
>>>> 
>>>> 
>>>> Although, we were able to set up NFSv4 referral using the native Ganesha
>>>> FSAL,
>>>> 
>>>> we could not get it fully functional for all Linux client system calls.
>>>> 
>>>> Basically, the NFSv4 spec suggests to return a NFS4ERR_MOVED on a
>>>> 
>>>> LOOKUP done for a remote export. However, this breaks the `stat` system
>>>> call on
>>>> 
>>>> Linux CentOS 7 (stat’ results in a LOOKUP,GETFH,GETATTR compound). An
>>>> easy way to
>>>> 
>>>> reproduce the broken behavior is:
>>>> 
>>>> 1) mount the root of the pseudo file system and
>>>> 
>>>> 2) issue a `stat` command on the remote export.
>>>> 
>>>> The stat returned are corrupt.
>>>> 
>>>> 
>>>> 
>>>> After digging into the CentOS 7 client code, we realized that the stat
>>>> operation
>>>> 
>>>> is never expected to follow the referral. However, switching to returning
>>>> NFS4_OK
>>>> 
>>>> for stat, then breaks `cd` or a `ls -l` command, because now we don't
>>>> know when
>>>> 
>>>> to follow the referral.
>>>> 
>>>> 
>>>> 
>>>> Does anyone have a successful experience in setting up the NFSv4
>>>> referrals that
>>>> 
>>>> they could share? Or, if some suggestions on what we might be doing
>>>> wrong?
>>>> 
>>>> 
>>>> 
>>>> Thanks
>>>> 
>>>> 
>>>> 
>>>> Virus-free. www.avast.com
>>>> 
>>>> 
>>> 
>>> 
>> 
> <nfs_remote_export1.pcap>

--
Chuck Lever



