Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-2.concepts.nl ([213.197.30.125]:45345 "EHLO
	smtp-2.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaJYUrX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Oct 2014 16:47:23 -0400
Message-ID: <544B7D9F.1070403@xmsnet.nl>
Date: Sat, 25 Oct 2014 12:38:23 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot
 laptop
References: <543ED24D.4070905@xmsnet.nl> <5443F5A1.1050004@xmsnet.nl>	<544A7933.3010702@xmsnet.nl> <544A7D5C.5060804@xmsnet.nl> <871tpx1gcx.fsf@x220.int.ebiederm.org>
In-Reply-To: <871tpx1gcx.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/24/2014 08:18 PM, Eric W. Biederman wrote:
> Hans de Bruin <jmdebruin@xmsnet.nl> writes:
>
>> On 10/19/2014 07:32 PM, Hans de Bruin wrote:
>>> On 10/15/2014 10:00 PM, Hans de Bruin wrote:
>>>> After playing an old dos game i am missing files on my nfsroot installed
>>>> laptop. Which one, wel /bin/ls is at least one of them. After a reboot
>>>> there all back again.  But not al is well. Some icons on my kde panel
>>>> where gone. I have seen this twice in the last day's
>>>>
>>>
>>> The problem appears immediately after starting dosemu so this bisectable
>>>
>>
>>
>> My bisect ended here:
>>
>> commit 8ed936b5671bfb33d89bc60bdcc7cf0470ba52fe
>> Author: Eric W. Biederman <ebiederman@twitter.com>
>> Date:   Tue Oct 1 18:33:48 2013 -0700
>>
>>
>>       vfs: Lazily remove mounts on unlinked files and directories.
>>
>>
>> I haven reverted it yet.
>>
>>
>>
>> Eric,
>>
>> Immediately after starting dosemu all files under mount point /usr are
>> gone. When I play a old dos game for a while (binaries are under /home)
>> even /bin/ls disappears. Al mounts are nfs, even /.
>>
>> Could you look in to this and cc this to the relevant kernel
>> mailinglist?
>
> At this point I don't know enough to reproduce this.
> What does /proc/mounts look like before you start dosemu?

bash-4.2$ cat /proc/mounts
rootfs / rootfs rw 0 0
10.10.0.1:/nfs/root/psion_14.1 / nfs 
rw,relatime,vers=3,rsize=4096,wsize=4096,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountproto=tcp,local_lock=all,addr=10.10.0.1 
0 0
devtmpfs /dev devtmpfs 
rw,relatime,size=1031016k,nr_inodes=220978,mode=755 0 0
proc /proc proc rw,relatime 0 0
sysfs /sys sysfs rw,relatime 0 0
tmpfs /run tmpfs rw,relatime,mode=755 0 0
devpts /dev/pts devpts rw,relatime,gid=5,mode=620 0 0
cgroup /sys/fs/cgroup cgroup rw,relatime,cpu 0 0
/dev/shm /tmp tmpfs rw,relatime,size=524288k 0 0
/dev/shm /dev/shm tmpfs rw,relatime,size=524288k 0 0
nfs:/nfs/usr/slackware-14.1/usr /usr nfs 
ro,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1 
0 0
nfs:/nfs/home /home nfs 
rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1 
0 0
nfs:/nfs/mp3 /mp3 nfs 
rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1 
0 0
nfs:/nfs/src /usr/src nfs 
rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1 
0 0
nfs:/nfs/video /video nfs 
rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1 
0 0

I now know why I do not see any file in /usr after running dosemu. The 
whole /usr mount disappears in /proc/mounts. When I remount it I have a 
usable laptop again. Running dosemu a second time does not remove the 
mount again. In the mean time I have seen /usr disappear after running 
other programs like xterm and firefox. But until now never after 
remouting it.

>
> My expectation is that you should only see this if the mount points are
> removed on the nfs server (which does not sound like it is the case).

This is a at home environment with a nfs server in the meter cupboard. I 
have not changed the exports.


> Although a transient malfunction of the nfs server or misplaced call to
> check_submounts_and_drop could cause mounts to disappear as well.
> During testing autofs was observed to have an inappropriate call

I am not using autofs

> to d_invalidate and it is unlikely but possible something like
> that is going on with nfs as well.
>
> Are your nfs mounts read-only or read-write?

/usr is mounted ro and exported ro

>
> What is your nfs-server and what is it exporting?
> Which distro are you running?

The nfs-server is slackware64 14.0 with a 3.4 kernel
part from exports:
/nfs/usr       -ro,async,no_subtree_check 10.10.0.0/16

The laptop is slackware(32 bit) 14.1 with yesterday's linus kernel

> Which version of dosemu are you running?

1.4.0.8

> How is dosemu configured to access files on your filesystem?

I do not understand what you mean by this. It uses ~/.dosemu/drive_c

-- 
Hans


