Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227Ab1D0VFO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 17:05:14 -0400
Message-ID: <4DB88503.9030909@RedHat.com>
Date: Wed, 27 Apr 2011 17:05:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
References: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>	 <23EF6F61-46F2-431B-8A44-A3E941688D65@oracle.com>	 <4DB7A084.2060009@panasas.com>	 <1303913806.13195.3.camel@lade.trondhjem.org>	 <4DB86605.3000304@panasas.com>	 <1303930718.23640.6.camel@lade.trondhjem.org>	 <4DB87B96.8090400@panasas.com> <1303936194.28589.2.camel@lade.trondhjem.org> <4DB87D93.8040205@panasas.com>
In-Reply-To: <4DB87D93.8040205@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 04/27/2011 04:33 PM, Benny Halevy wrote:
> On 2011-04-27 23:29, Trond Myklebust wrote:
>> On Wed, 2011-04-27 at 23:24 +0300, Benny Halevy wrote:
>>> On 2011-04-27 21:58, Trond Myklebust wrote:
>>>> On Wed, 2011-04-27 at 21:52 +0300, Benny Halevy wrote:
>>>>> On 2011-04-27 17:16, Trond Myklebust wrote:
>>>>>> On Wed, 2011-04-27 at 07:50 +0300, Benny Halevy wrote:
>>>>>>> On 2011-04-25 17:11, Chuck Lever wrote:
>>>>>>>> Hey all-
>>>>>>>>
>>>>>>>> So what are we going to do when adding NFSv4.2 to this mix?  Will we
>>>>>>>> then have to freeze both the NFSv4.1 and NFSv4.0 procedure API in the
>>>>>>>> kernel?  Seems painful.
>>>>>>>
>>>>>>> Good question.
>>>>>>> How about changing the stat pseudo-file format to include an op
>>>>>>> identifier along with its respective counter, printing a line per op?
>>>>>>
>>>>>> We already have that in /proc/self/mountstats
>>>>>>
>>>>>>
>>>>>
>>>>> You mean /proc/self/status?
>>>>
>>>> No.
>>>
>>> So can you please explain what you meant by the /proc/self/mountstats
>>> example?
>>>
>>> This is what I see:
>>>
>>> $ head -3 /proc/self/mountstats
>>> device rootfs mounted on / with fstype rootfs
>>> device /proc mounted on /proc with fstype proc
>>> device /sys mounted on /sys with fstype sysfs
>>>
>>> Benny
>>
>> Try mounting an NFS partition. When I do, I also get:
>>
>> device ila.local:/raid0/data/vol0 mounted on /net/ila.local/raid0/data/vol0 with fstype nfs statvers=1.0
>> 	opts:	rw,vers=3,rsize=32768,wsize=32768,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.20,mountvers=3,mountport=993,mountproto=udp
>> 	age:	3
>> 	caps:	caps=0x3fcf,wtmult=4096,dtsize=4096,bsize=0,namlen=255
>> 	sec:	flavor=1,pseudoflavor=1
>> 	events:	4 101 0 0 6 0 107 0 0 0 0 0 12 0 0 0 0 0 0 0 0 0 0 0 0 
>> 	bytes:	0 0 0 0 0 0 0 0 
>> 	RPC iostats version: 1.0  p/v: 100003/3 (nfs)
>> 	xprt:	tcp 826 1 1 0 2 24 24 0 24 0
>> 	per-op statistics
>> 	        NULL: 0 0 0 0 0 0 0 0
>> 	     GETATTR: 6 6 0 752 672 0 1 1
>> 	     SETATTR: 0 0 0 0 0 0 0 0
>> 	      LOOKUP: 0 0 0 0 0 0 0 0
>> 	      ACCESS: 5 5 0 692 600 0 1 1
>> 	    READLINK: 0 0 0 0 0 0 0 0
>> 	        READ: 0 0 0 0 0 0 0 0
>> 	       WRITE: 0 0 0 0 0 0 0 0
>> 	      CREATE: 0 0 0 0 0 0 0 0
>> 	       MKDIR: 0 0 0 0 0 0 0 0
>> 	     SYMLINK: 0 0 0 0 0 0 0 0
>> 	       MKNOD: 0 0 0 0 0 0 0 0
>> 	      REMOVE: 0 0 0 0 0 0 0 0
>> 	       RMDIR: 0 0 0 0 0 0 0 0
>> 	      RENAME: 0 0 0 0 0 0 0 0
>> 	        LINK: 0 0 0 0 0 0 0 0
>> 	     READDIR: 0 0 0 0 0 0 0 0
>> 	 READDIRPLUS: 7 7 0 1112 13832 0 35 36
>> 	      FSSTAT: 1 1 0 104 84 0 1 1
>> 	      FSINFO: 2 2 0 208 160 0 0 0
>> 	    PATHCONF: 1 1 0 104 56 0 0 0
>> 	      COMMIT: 0 0 0 0 0 0 0 0
>>
>> Providing this kind of statistic was _exactly_ the reason for adding
>> mountstats in the first place.
> 
> Ah, cool!
> This makes much more sense now :)
FYI... both mountstats and nfsiostat using this file...

steved.
