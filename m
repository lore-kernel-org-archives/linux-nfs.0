Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-1.concepts.nl ([213.197.30.124]:37098 "EHLO
	smtp-1.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbaJYWDv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Oct 2014 18:03:51 -0400
Message-ID: <544C1E40.6070901@xmsnet.nl>
Date: Sun, 26 Oct 2014 00:03:44 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot
 laptop
References: <543ED24D.4070905@xmsnet.nl> <5443F5A1.1050004@xmsnet.nl>	<544A7933.3010702@xmsnet.nl> <544A7D5C.5060804@xmsnet.nl>	<871tpx1gcx.fsf@x220.int.ebiederm.org> <544B7D9F.1070403@xmsnet.nl> <87k33ow65k.fsf@x220.int.ebiederm.org>
In-Reply-To: <87k33ow65k.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/25/2014 04:55 PM, Eric W. Biederman wrote:
> Hans de Bruin <jmdebruin@xmsnet.nl> writes:
>
>> On 10/24/2014 08:18 PM, Eric W. Biederman wrote:
>
> [...]
>
>>> At this point I don't know enough to reproduce this.
>>> What does /proc/mounts look like before you start dosemu?
>>
>> bash-4.2$ cat /proc/mounts
>> rootfs / rootfs rw 0 0
>> 10.10.0.1:/nfs/root/psion_14.1 / nfs
>> rw,relatime,vers=3,rsize=4096,wsize=4096,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountproto=tcp,local_lock=all,addr=10.10.0.1
>> 0 0
>> devtmpfs /dev devtmpfs rw,relatime,size=1031016k,nr_inodes=220978,mode=755 0 0
>> proc /proc proc rw,relatime 0 0
>> sysfs /sys sysfs rw,relatime 0 0
>> tmpfs /run tmpfs rw,relatime,mode=755 0 0
>> devpts /dev/pts devpts rw,relatime,gid=5,mode=620 0 0
>> cgroup /sys/fs/cgroup cgroup rw,relatime,cpu 0 0
>> /dev/shm /tmp tmpfs rw,relatime,size=524288k 0 0
>> /dev/shm /dev/shm tmpfs rw,relatime,size=524288k 0 0
>> nfs:/nfs/usr/slackware-14.1/usr /usr nfs
>> ro,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1
>> 0 0
>> nfs:/nfs/home /home nfs
>> rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1
>> 0 0
>> nfs:/nfs/mp3 /mp3 nfs
>> rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1
>> 0 0
>> nfs:/nfs/src /usr/src nfs
>> rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1
>> 0 0
>> nfs:/nfs/video /video nfs
>> rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.0.1,mountvers=3,mountport=38337,mountproto=udp,local_lock=none,addr=10.10.0.1
>> 0 0
>>
>> I now know why I do not see any file in /usr after running dosemu. The whole
>> /usr mount disappears in /proc/mounts. When I remount it I have a usable laptop
>> again. Running dosemu a second time does not remove the mount again. In the mean
>> time I have seen /usr disappear after running other programs like xterm and
>> firefox. But until now never after remouting it.
>
> That is interesting.

boot
run dosemu -> /usr unmounted
mount /usr
run dosemu -> /usr still mounted
sync; echo 3 > /proc/sys/vm/drop_caches
run dosemu -> /usr unmounted

>
> It sounds like occassionally your /home mount disappears as well.
>

I have not seen that happening

...

>
> I expect what needs to happen is to confirm that nfs directory entry
> revalidation is buggy, and at least for the short term re-add the nfs
> logic that will avoid dropping a dentry if it is a mount point, or
> path to a mount point, to avoid the nfs bugs.
>

ok, I will go in waiting mode.

-- 
Hans


