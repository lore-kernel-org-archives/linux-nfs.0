Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41963 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615Ab0DSRAz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 13:00:55 -0400
Message-ID: <4BCC8C06.1080106@oracle.com>
Date: Mon, 19 Apr 2010 12:59:50 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: =?ISO-8859-1?Q?Stefan_Kr=FCger?= <stadtkind2@gmx.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: strange performance issues with OS X 10.6 client
References: <20100415214900.GA4143@web.de> <20100419122120.GA3716@gmx.de>
In-Reply-To: <20100419122120.GA3716@gmx.de>
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/19/2010 08:21 AM, Stefan Krüger wrote:
> On Thu, 15 Apr 2010, Stefan Krüger wrote:
>
>> Hello list,
>>
>> I have some really strange nfs performance issues
>>
>> NFS server is Fedora 12, running
>> * kernel-2.6.32.11-99.fc12.x86_64 and
>> * nfs-utils-1.2.1-4.fc12.x86_64
>> * nfs shared /home is ext4 with default mount options
>>
>> /etc/exports:
>> /home   192.168.1.0/255.255.255.0(rw,sync)
>>
>> nfs and nfslock are up and running
>>
>> Nothing else touched on the server nfs-wise.
>>
>> NFS client is Mac OS X, version 10.6.3
>>
>> My /home dir is automounted on the Mac with the following mount options:
>> * nosuid,nodev,resvport,rdirplus,rwsize=1048576
>> (nfsv3 and tcp are default, I have also tried udp, and with and without
>> rdirplus, with different read/write sizes (started with 32k, less for udp,
>> and then cranked it up to 1m to make the beachball appear less often), but I
>> still have issues no matter which options I chose)
>>
>> Anyway, I'm stuck now, surfing the web with Safari is a very unpleasant
>> experience on nfs, beachball every now and then together with a huge amount
>> of network traffic (RX with 20MB/s+ peaks), not unusual to see several
>> gigabytes received after some minutes browsing, XCode shows a ''The
>> document "SomeFile.m" could not be saved.''-error after some edits, Opera
>> hangs for minutes when closing, etc etc.
>>
>> It's horrible :(
>>
>> Another example, extracting
>> http://www.bignerdranch.com/solutions/Cocoa-3rd.tgz took over 3min!
>>
>> $ time tar xzf Cocoa-3rd.tgz
>> 0.169u 3.198s 5:51.10 0.9%	0+0k 1+6972io 0pf+0w
>> $ time rm -rf Solutions-Cocoa-3rd/
>> 0.014u 0.477s 0:45.59 1.0%	0+0k 1+1io 0pf+0w
>>
>> So any help or hints really appreciated
>
> So, no answers yet, but I did some more tests, i.e. I tried extracting the
> Cocoa-3rd.tgz (2.2MB, 12MB untar'ed) on FreeBSD 8.0-REL (running inside
> VMWare though), and still it was much faster (5:51.10 vs 0:09.35) than
> extracting on bare metal fedora12:
>
> $ time tar xfz Cocoa-3rd.tgz
> 0.104u 1.474s 0:09.35 16.7%	0+0k 0+4896io 0pf+0w
> $ time rm -rf Solutions-Cocoa-3rd
> 0.006u 0.160s 0:01.24 12.9%	0+0k 0+0io 0pf+0w
>
> I captured the nfs traffic with tcpdump (tcpdump -i eth1 -s 0 -w nfs.out
> host nfssrv and port 2049) on both freebsd8 (interface for freebsd is a bit
> different ofc) and fedora12 while running
>
> tar xfz Cocoa-3rd.tgz Solutions-Cocoa-3rd/02_GetStarted
>
> (which extracts just a couple of files) , you can find them here:
>
> Fedora 12 tcpdump ->  http://www.dpaste.org/5cvp/
> FreeBSD 8 tcpdump ->  http://www.dpaste.org/uCGX/

The number of packets is around 1800 for the FreeBSD server and around 
1940 for the Linux server.  The RPC counts you posted in a later email 
show that Linux does more LOOKUP and ACCESS requests.  But generally, it 
looks like your client is doing roughly the same amount of work in both 
cases.

But what catches my eye in the F12 tcpdump is that there are pauses 
where the server reply is delayed by a few milliseconds after a SETATTR 
or COMMIT.  This looks normal, since disk writes can take a few 
milliseconds.

FreeBSD doesn't appear to have these pauses, so I suspect FreeBSD is 
doing something illegal.  No NFS server can turn a SETATTR around in 
just a few microseconds and claim that it is on permanent storage, 
unless it has some kind of NVRAM.

-- 
chuck[dot]lever[at]oracle[dot]com
