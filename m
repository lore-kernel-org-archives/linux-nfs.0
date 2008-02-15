From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Performance question
Date: Fri, 15 Feb 2008 11:18:06 -0500
Message-ID: <12C4649C-537F-4850-AE77-78A130B54B37@oracle.com>
References: <90d010000802140740y3ff2706ybc169728fbafbfb4@mail.gmail.com> <42996ba90802140827p533779c6o8ab404400be51fdc@mail.gmail.com> <80E378BD-86F7-4009-832A-2978A6FB4600@oracle.com> <90d010000802150737x2ad0739dmeaaa24dc2845e81a@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "NFS list" <linux-nfs@vger.kernel.org>,
	"Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
To: "Font Bella" <fontbella@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:10349 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbYBOQSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2008 11:18:52 -0500
In-Reply-To: <90d010000802150737x2ad0739dmeaaa24dc2845e81a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 15, 2008, at 10:37 AM, Font Bella wrote:
> Dear all,
>
> I finally got it to work, after much pain/testing. Here are my config
> notes (just for the record).
> Thanks Marcelo and Chuck!
>
> NFS setup
> =========
>
> Documentation
> -------------
>
> * http://billharlan.com/pub/papers/NFS_for_clusters.html
> * http://nfs.sourceforge.net/nfs-howto/ 
> ar01s05.html#nfsd_daemon_instances
>
> Setting
> -------
>
> We use package nfs-kernel-server, i.e. we use the kernel-space nfs  
> server,
> which is faster than nfs-user-server.
>
> We use NFS version 3.
>
> Configuration
> -------------
>
> Make sure we are using nfs version 3. This seems to be the default  
> with
> package nfs-kernel-server. Check from client side with::
>
>         cat /proc/mounts
>
> Use UDP for packet transmission, i.e. use option 'proto=udp' in your
> /etc/fstab, /etc/auto.home (if using automounts), or in general, in  
> any mount
> command. Check from client side also with 'cat /proc/mounts'.
>
> Make sure you have enough nfsd server threads. See if your server  
> is receiving
> too many overlapping requests with
>
>   $ grep th /proc/net/rpc/nfsd
>
> Ours isn't, so we increase the number of threads used by the server to
> 32 by changing
> RPCNFSDCOUNT=32 in /etc/default/nfs-kernel-server (Debian  
> configuration file
> for startup scripts). Remember to restart nfs-kernel-server for  
> changes to
> take effect.
>
> In the server side, use 'async' option in /etc/exports. This was a  
> crucial
> step to get good performance.
>
> Finally, try different values of rsize and wsize in your
> /etc/fstab, /etc/auto.home (if using automounts), or in general, in  
> any mount
> command. Check from client side also with 'cat /proc/mounts'.
> Test your favourite benchmark with different rsize,wsize and look  
> for an
> optimal value.
>
> ALL the steps above were necessary for me to get good performance, but
> the last step was
> crucial, since I got very different performances depending on the
> value of rsize/wsize.

I'm glad you were able to make progress.  32 server threads is  
actually fairly conservative; you might consider 128 or more if you  
have more than a few clients.

I want to make sure you understand the limitations and risks of using  
UDP and the "async" export option, however.

1.  "async" is no longer the default because it introduces a silent  
data corruption risk.  With NFSv3, data write operations are already  
asynchronous, with a subsequent COMMIT, so that they are safe.  The  
client now knows when data has hit stable storage and can thus delete  
its cached copy safely.

I urge you to read the NFS FAQ discussion on the "async" export  
option and reconsider its use in production.

2.  UDP is no longer the default because it also introduces a silent  
data corruption risk, since the IP ID field (which UDP depends on for  
reassembling datagrams larger than a single link-layer frame) is only  
16 bits wide.  If this field should wrap, datagram reassembly is  
compromised.  The UDP datagram checksum is weak enough that the  
receiving end probably won't detect the reassembly errors.

In addition, UDP will likely perform poorly in situations involving  
more than a few clients.  It's congestion control algorithm is unable  
to handle large amounts of concurrent network traffic since it  
doesn't have a packet ACK mechanism like TCP does.  The fact that  
your performance was best at such a small r/wsize (you mentioned 2048  
in your earlier e-mail) suggests you have a network environment that  
would benefit enormously from using TCP.


So, our recommendation these days is to use the default "sync" export  
setting, and use NFSv3 over TCP if at all possible.  (The HOWTO may  
be out of date in this regard).  If you are not able to achieve good  
performance results with these settings, you can e-mail the list  
again and we can do further analysis.



> On Thu, Feb 14, 2008 at 5:56 PM, Chuck Lever  
> <chuck.lever@oracle.com> wrote:
>> On Feb 14, 2008, at 11:27 AM, Marcelo Leal wrote:
>>>  Hello all,
>>> There is a great diff between access the raw discs and through LVM,
>>> with some kind of RAID, and etc. I think you should use NFS v3, and
>>> it's hard to think that without you explicitally configure it to use
>>> v2, it using...
>>> A great diff between v2 and v3 is that v2 is always "async", what  
>>> is a
>>> performance burst. Are you sure that in the new environment is  
>>> not v3?
>>> In the new stable version (nfs-utils), debian is sync by default.  
>>> I'm
>>> used to "8192" transfer sizes, and was the best perfomance in my
>>> tests.
>>
>>  As Marcelo suggested, this could be nothing more than the change in
>>  default export options (see exports(8) -- the description of the  
>> sync/
>>  async option) between sarge and etch.  This was a change in the nfs-
>>  utils package done a while back to improve data integrity guarantees
>>  during server instability.
>>
>>  You can test this easily by explicitly specifying sync or async in
>>  your /etc/exports and trying your test.
>>
>>  It especially effects NFSv2, as all NFSv2 writes are FILE_SYNC (ie
>>  they must be committed to permanent storage before the server
>>  replies) -- the async export option breaks that guarantee to improve
>>  performance.  There is some further description in the NFS FAQ at
>>  http://nfs.sourceforge.net/ .
>>
>>  The preferred way to get "async" write performance is to use NFSv3.
>>
>>
>>
>>>  Would be nice if you could test another network service writing in
>>> that server.. like ftp, or iscsi.
>>>  Another question, the discs are "local" or SAN? There is no
>>> concurrency?
>>>
>>> ps.: v2 has a 2GB file size limit AFAIK.
>>>
>>>  Leal.
>>>
>>> 2008/2/14, Font Bella <fontbella@gmail.com>:
>>>> Hi,
>>>>
>>>>  some of our apps are experiencing slow nfs performance in our new
>>>> cluster, in
>>>>  comparison with the old one. The nfs setups for both clusters are
>>>> very
>>>>  similar, and we are wondering what's going on. The details of
>>>> both setups are
>>>>  given below for reference.
>>>>
>>>>  The problem seems to occur with apps that do heavy i/o, creating,
>>>> writing,
>>>>  reading, and deleting many files. However, writing or reading a
>>>> large file
>>>>  (as measure with `time dd if=/dev/zero of=2gbfile bs=1024
>>>> count=2000`) is not
>>>>  slow.
>>>>
>>>>  We have performed some tests with the disk benchmark 'dbench',
>>>> which reports
>>>>  i/o performance of 60 Mb/sec in the old cluster down to about 6Mb/
>>>> sec in the
>>>>  new one.
>>>>
>>>>  After noticing this problem, we tried the user-mode nfs server
>>>> instead of the
>>>>  kernel-mode server, and just installing the user-mode server
>>>> helped improving
>>>>  throughput up to 12 Mb/sec, but still far away from the good old
>>>> 60 Mb/sec.
>>>>
>>>>  After going through the "Optimizing NFS performance" section of  
>>>> the
>>>>  NFS-Howto and tweaking the rsize,wsize parameters (the optimal
>>>> seems to be
>>>>  2048, which seems kind of weird to me, specially compared to the
>>>> 8192 used in
>>>>  the old cluster), throughput increased to 21 Mb/sec, but is still
>>>> too far
>>>>  from the old 60Mb/sec.
>>>>
>>>>  We are stuck at this point. Any help/comment/suggestion will be
>>>> greatly
>>>>  appreciated.
>>>>  /P
>>>>
>>>>  **************************** OLD CLUSTER
>>>> *****************************
>>>>
>>>>  SATA disks.
>>>>
>>>>  Filesystem: ext3.
>>>>
>>>>  * the version of nfs-utils you are using: I don't know. It's the
>>>> most
>>>>   recent version in debian sarge (oldstable).
>>>>
>>>>  user-mode nfs server.
>>>>
>>>>  nfs version 2, as reported with rpcinfo.
>>>>
>>>>  * the version of the kernel and any non-stock applied kernels:
>>>> 2.6.12
>>>>  * the distribution of linux you are using: Debian sarge x386 on
>>>> Intel Xeon
>>>>   processors.
>>>>  * the version(s) of other operating systems involved: no other OS.
>>>>
>>>>  It is also useful to know the networking configuration connecting
>>>> the hosts:
>>>>  Typical beowulf setup, with all servers connected to a switch,
>>>> 1Gb network.
>>>>
>>>>  /etc/exports:
>>>>
>>>>  /srv/homes      192.168.1.0/255.255.255.0 (rw,no_root_squash)
>>>>
>>>>  /etc/fstab:
>>>>
>>>>  server:/srv/homes/user /mnt/user nfs
>>>> rw,hard,intr,rsize=8192,wsize=8192 0 0
>>>>
>>>>  **************************** NEW CLUSTER
>>>> *****************************
>>>>
>>>>  SAS 10k disks.
>>>>
>>>>  Filesystem: ext3 over LVM.
>>>>
>>>>  * the version of nfs-utils you are using: I don't know. It's the
>>>> most
>>>>   recent version in debian etch (stable).
>>>>
>>>>  kernel-mode nfs server.
>>>>
>>>>  nfs version 2, as reported with rpcinfo.
>>>>
>>>>  * the version of the kernel and any non-stock applied kernels:
>>>> 2.6.18-5-amd64
>>>>  * the distribution of linux you are using: Debian etch AMD64 on
>>>> Intel Xeon
>>>>   processors.
>>>>  * the version(s) of other operating systems involved: no other OS.
>>>>
>>>>  It is also useful to know the networking configuration connecting
>>>> the hosts:
>>>>  Typical beowulf setup, with all servers connected to a switch,
>>>> 1Gb network.
>>>>
>>>>  /etc/exports:
>>>>
>>>>  /srv/homes      192.168.1.0/255.255.255.0 (no_root_squash)
>>>>
>>>>  mount options:
>>>>
>>>>  rsize=8192,wsize=8192
>>>>  -
>>>>  To unsubscribe from this list: send the line "unsubscribe linux-
>>>> nfs" in
>>>>  the body of a message to majordomo@vger.kernel.org
>>>>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>>
>>>
>>>
>>> --
>>> pOSix rules
>>> -
>>> To unsubscribe from this list: send the line "unsubscribe linux-
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>  --
>>  Chuck Lever
>>  chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



