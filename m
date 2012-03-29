Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:54634 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758417Ab2C2SHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2012 14:07:22 -0400
Message-ID: <4F74A4D5.1040802@cora.nwra.com>
Date: Thu, 29 Mar 2012 12:07:17 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Dr James Bruce Fields <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
References: <loom.20120329T182500-467@post.gmane.org>  <1333040091.5547.32.camel@lade.trondhjem.org>  <4F749CCA.3000400@cora.nwra.com> <1333042863.5547.37.camel@lade.trondhjem.org>
In-Reply-To: <1333042863.5547.37.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/29/2012 11:40 AM, Myklebust, Trond wrote:
> On Thu, 2012-03-29 at 11:32 -0600, Orion Poplawski wrote:
>> On 03/29/2012 10:54 AM, Myklebust, Trond wrote:
>>> On Thu, 2012-03-29 at 16:28 +0000, Orion Poplawski wrote:
>>>> I filed a bug here: https://bugzilla.redhat.com/show_bug.cgi?id=808112
>>>>
>>>> Description of problem:
>>>>
>>>> client A:
>>>> touch blah
>>>> ln -s blah blahlink
>>>>
>>>> client B:
>>>> open("blahlink", O_RDONLY|O_CREAT, 0666) = -1 EEXIST (File exists)
>>>
>>> That sounds more like a server bug. It shouldn't be replying
>>> NFS4ERR_EXIST here, since this isn't an exclusive create; it should
>>> rather be replying with NFS4ERR_SYMLINK.
>>>
>>> Which server are you testing against, and what does the wireshark trace
>>> show?
>>>
>>
>> Well, I can reproduce it against an EL6.2 server with an EL6.2 client with v3.
>>    First tests were with and EL5.8 server.  I can't reproduce with Fedora
>> clients against the EL6.2 server with v3.
>>
>> The EL6.2 client/server exchange in nfsel.log, F15/EL6.2 exchange in nfsf15.log
>>
>> The EL6.2 client appears to be using a version 4 call even though I think it's
>> mounted v3:
>>
>> saga:/export/sw on /data/sw type nfs
>> (rw,noatime,intr,rsize=32768,wsize=32768,sloppy,addr=10.10.10.2)
>
>
> It has got to be mounted v4. I'd check /proc/mounts.
>

saga:/export/sw /data/sw nfs 
rw,noatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.10.10.2,mountvers=3,mountport=51114,mountproto=udp,local_lock=none,addr=10.10.10.2 
0 0

But I see:

Network File System, Ops(3): PUTFH ACCESS GETATTR
     [Program Version: 4]
     [V4 Procedure: COMP (1)]


>> Going back to v4 on EL5.8 server: nfsv4el.log, nfsv4f18.log
>>
>> Both get NFS4ERR_EXIST in this case.
>
> Which is an obvious server bug: it should be sending NFS4ERR_SYMLINK in
> reply to that OPEN.
>
> Bruce?
>

I can reproduce with a 3.4.0-0.rc0.git1.2.fc18 server as well.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
