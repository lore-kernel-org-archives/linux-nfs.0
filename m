Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:54078 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab0C3T3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Mar 2010 15:29:09 -0400
Message-ID: <4BB25091.2070201@oracle.com>
Date: Tue, 30 Mar 2010 15:27:13 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Anton Starikov <ant.starikov@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4 in combination with root over NFS3, hangs and deadlocks
References: <EE102A23-736F-4905-BAAF-1BF03064F529@gmail.com> <EDDF2B79-DBFA-4701-BEFF-0AEACD63A3DC@gmail.com> <4BB24A53.1090005@oracle.com> <844AD38F-D46D-4641-8250-33377CFECFCB@gmail.com>
In-Reply-To: <844AD38F-D46D-4641-8250-33377CFECFCB@gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/30/2010 03:11 PM, Anton Starikov wrote:
> On Mar 30, 2010, at 9:00 PM, Chuck Lever wrote:
>
>> On 03/30/2010 02:30 PM, Anton Starikov wrote:
>>> If it is already resolved problem, can someone point me into direction of particular patch?
>>
>> As far as I know NFSv4 is known not to work with an NFSv3 root, in any kernel.
>
>
> But NFS4-root (does it work finally?) isn't always desirable solution. Especially if different OSes used for client/server.
>
> And it seems that generally it works, just some deadlock occurs, probably related to caching of some credentials.

No, NFSv4 root is known to have problems, and is unsupported, as far as 
I know.

> Anton,
>
>>> Anton.
>>>
>>>
>>> On Mar 29, 2010, at 5:14 PM, Anton Starikov wrote:
>>>
>>>> Hi,
>>>>
>>>> Early (year ago and recently) I reported about my faults in getting working NFS4 mounts (primary automounting /home) with system booted with NFSv3-root. It always used to silently hang nodes with zero output in the logs. It was definitely client issue (I tried it with different versions of linux and solaris servers)
>>>>
>>>> Although I can't get simple and reproducible test-case, because hangs appears randomly, it can happen in 1hour, it can happen in 5 days, but it always will happen after some time. But this time I got some some improvement.
>>>>
>>>> With 2.6.32.9-70.fc12.x86_64 kernel and fresh nfs-utils from Fedora-12, after NFS4 mounts hangs, NFS3 mounts and node itself still continue to work, which gives chance to investigate problem.
>>>>
>>>> Can you give me instruction how to collect all necessary information to figure out where the bug is?
>>>>
>>>> As starting point I will attach output of echo "t">   sysrq-trigge, list of NFS mounts.
>>>>
>>>> Thanks,
>>>> Anton.
>>>>
>>>> # cat /proc/mounts | grep nfs
>>>> 172.19.8.1:/export/share/cluster/fedora-root / nfs ro,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,nolock,proto=udp,port=65535,timeo=7,retrans=3,sec=sys,mountport=65535,addr=172.19.8.1 0 0
>>>> none /var/lib/nfs tmpfs rw,relatime 0 0
>>>> sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0
>>>> 172.19.8.1:/export/share/cluster/admin /root nfs rw,noatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,noacl,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.19.8.1,mountvers=3,mountport=44114,mountproto=tcp,addr=172.19.8.1 0 0
>>>> 172.19.8.1:/export/share/cluster/checkpoint /mnt/checkpoint nfs rw,noatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,noacl,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.19.8.1,mountvers=3,mountport=52574,mountproto=udp,addr=172.19.8.1 0 0
>>>> 172.19.8.1:/export/share/software /software nfs rw,noatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,noacl,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.19.8.1,mountvers=3,mountport=44114,mountproto=tcp,addr=172.19.8.1 0 0
>>>> 172.19.8.1:/export/share/cluster/torque /var/torque nfs rw,noatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,noacl,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.19.8.1,mountvers=3,mountport=44114,mountproto=tcp,addr=172.19.8.1 0 0
>>>> 172.19.8.1:/export/share/common/ /common nfs4 rw,noatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.19.8.133,addr=172.19.8.1 0 0
>>>> 172.19.8.1:/export/home/alfons/ /home/alfons nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.19.8.133,addr=172.19.8.1 0 0
>>>>
>>>> <log1.txt.gz>
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>> --
>> chuck[dot]lever[at]oracle[dot]com
>


-- 
chuck[dot]lever[at]oracle[dot]com
