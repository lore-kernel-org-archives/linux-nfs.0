Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:36269 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaLOM5D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 07:57:03 -0500
Received: by mail-vc0-f176.google.com with SMTP id hq12so5301391vcb.7
        for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2014 04:57:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1412150749290.1119@planck.local>
References: <CAF1in6QVkgyuC7VQ5QdYnYtPRJgArDwg5sXtKiAvyszCcQoZ-g@mail.gmail.com>
	<CAF1in6RCyK4VMM3j1ZD=1D25+cFU9YGg-UhR-kuYcNWNk+Stzg@mail.gmail.com>
	<alpine.OSX.2.19.9992.1412150749290.1119@planck.local>
Date: Mon, 15 Dec 2014 07:57:02 -0500
Message-ID: <CAHQdGtRqO_LRxCsx6+uN03zOcWFGeHeaNaSkA3mYGwyU9FNTPw@mail.gmail.com>
Subject: Re: Fwd: NFS and Memory Buffers
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Pablo Silva <psilvao@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 15, 2014 at 7:52 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> Dear Pablo,
>
>         Why are you restarting snmpd between flushing cache and reading
> memory values?  On a running system you can probably expect the
> cache to immediately start to fill after a flush anyway.
> y
> Ben
>
> On Mon, 15 Dec 2014, Pablo Silva wrote:
>
>> Dear Readers:
>>
>>      My boss has entrusted me to analyze why the memory buffers are
>> not released a Linux server with Centos 6.4.?
>>
>>     As informs me, the current reading is:
>>
>>
>> [root@bck ~]# free -m
>>              total       used       free     shared    buffers     cached
>> Mem:         15936      15788        147          0       6746        438
>> -/+ buffers/cache:       8604       7332
>> Swap:         2047          0       2047
>> [root@bck ~]#
>> [root@bck ~]#
>> [root@bck ~]# echo 3 > /proc/sys/vm/drop_caches && service snmpd
>> restart && free -m
>> Stopping snmpd:                                            [  OK  ]
>> Starting snmpd:                                            [  OK  ]
>>              total       used       free     shared    buffers     cached
>> Mem:         15936        509      15426          0         93         16
>> -/+ buffers/cache:        400      15536
>> Swap:         2047          0       2047
>> [root@bck ~]#
>>
>>    I can not find the solution to release the memory buffer and cache
>> memory so grateful for any hint for finding the solution to this
>> "problem".
>>
>> -Paul
>>

See the top entry on googling "why does linux cache memory":
http://www.linuxatemyram.com/


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
