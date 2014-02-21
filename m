Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f171.google.com ([209.85.128.171]:45892 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663AbaBUJx0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Feb 2014 04:53:26 -0500
Received: by mail-ve0-f171.google.com with SMTP id pa12so3032614veb.30
        for <linux-nfs@vger.kernel.org>; Fri, 21 Feb 2014 01:53:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5306418B.9060007@RedHat.com>
References: <CA+NKcRwjoaeQUZEGSeVC+Tfa3jDzvTLt1RBjSQrkj6KJMcC-zg@mail.gmail.com>
	<5306418B.9060007@RedHat.com>
Date: Fri, 21 Feb 2014 12:53:25 +0300
Message-ID: <CA+NKcRzkHKqJ5sSJHLbZcJdOoDS6c2ef-D3CsGkOsw1uSyTmMg@mail.gmail.com>
Subject: Re: Reliable NFS statistics tool to monitoring all incoming network traffic
From: Pavel Karneliuk <pavel.karneliuk@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve,

Thank you for your answer. The mountstats(8) and nfsiostat(8) are
well, but I am interesting in some network sniffer that listens all
network traffic in promiscuous mode.

I think about researching and development new solution.
Fast, reliable and extensible tool with deep packet inspection of NFS
operations and supporting NFS version 2/3/4 over TCP/UDP protocols.
Something based on libpcap, TCP reassembling suchlike dissectors from
Wireshark, and full parsing headers of NFS operations on the fly.

Would such tool be useful for community, NFS developers and end-users?
What do you think?

Regards,
Pavel K

2014-02-20 20:55 GMT+03:00 Steve Dickson <SteveD@redhat.com>:
>
>
> On 02/20/2014 10:39 AM, Pavel Karneliuk wrote:
>> Hello linux-nfs members,
>>
>> I am looking for some tool for monitoring all incoming traffic on the
>> wire and collecting NFSv3 operations over TCP transport protocol in
>> 1G-10G networks.
>>
>> Could you advise me some fast and reliable utility?
>>
>> I have tried NFSwatch tool, but its results are not reliable.
>> At first, I mount NFSv3 directory with TCP transport protocol and wsize=512k
>>
>> sudo mount -v -t nfs 10.6.136.187:/share /mnt/nfs-fedora/ -o
>> rw,vers=3.0,tcp,wsize=524288
>>
>> then I write 10Mb file to NFS server:
>>
>> sudo dd if=/dev/zero of=/mnt/nfs-fedora/zero.data bs=1M count=10
>>
>> I expect to see 20 WRITE operations (10Mb / 512Kb == 20).
>> The nfsstat (nfsstat --nfs -3 -Z) shows exactly 20 WRITE operations,
>> because it takes statistic from the kernel.
>>
>> When I try to get the same result with NFSwatch by (sudo nfswatch -all
>> -procs3 -t 20)
>> I get unreproducible results with 1 or 2 registered WRITE operations.
>> NFSwatch works well on NFSv3 over UDP, but loses almost all READ/WRITE
>> operations in case of TCP protocol.
>> I have checked its source code and found that NFSwatch doesn't
>> performs reassembling TCP streams between NFS server and NFS client.
>> It just looks at TCP segment and expects headers of RPC/NFSv3
>> operations exactly after TCP header.
>>
>> The tcpdump works similarly. Wireshark(and Tshark) is too slow for
>> live 1G-10G NFSv3/TCP traffic capturing and filtration.
>>
>>
>> Would you suggest some alternative utils, solutions or workarounds?
> You can try mountstats(8) or nfsiostat(8). Both of them
> manipulate data collected in /proc/self/mountstats
>
> steved.
>
