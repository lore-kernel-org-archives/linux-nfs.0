From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 23 Jun 2008 15:40:40 +0300
Message-ID: <485F99C8.2000800@panasas.com>
References: <OF5D1728DA.B4C6E2E0-ON65257471.0027ACA3-65257471.002CF647@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:5473 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753655AbYFWMmQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 08:42:16 -0400
In-Reply-To: <OF5D1728DA.B4C6E2E0-ON65257471.0027ACA3-65257471.002CF647@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 23, 2008, 11:11 +0300, Krishna Kumar2 <krkumar2@in.ibm.com> wrote:
> Hi Benny,
> 
>> According to dd's man page, the f{,date}sync options tell it to
>> "physically write output file data before finishing"
>> If you kill it before that you end up with dirty data in the cache.
>> What exactly are you trying to measure, what is the expected application
>> workload?
> 
> I changed my test to do what you were doing instead of killing
> dd's, etc. The end application is DB2 and it is using multiple
> processes and I wanted to simulate that with micro-benchmarks.
> The only reliable way to benchmark bandwidth for multiple
> processes is to kill the tests after running them for some time
> instead of letting them run till conclusion.

BTW, iozone (http://www.iozone.org/) might be your friend if you're
looking for a reliable I/O benchmark (w/ -e and -c options to include
fsync and close).

> 
>> ext3 mount options: noatime
>> nfs mount options: rsize=65536,wsize=65536
>> dd options: bs=64k count=10k conv=fsync
>>
>> (write results average of 3 runs)
>> write local disk:     47.6 MB/s
>> write loopback nfsv3: 30.2 MB/s
>> write remote nfsv3:   29.0 MB/s
>> write loopback nfsv4: 37.5 MB/s
>> write remote nfsv4:   29.1 MB/s
>>
>> read local disk:      50.8 MB/s
>> read loopback nfsv3:  27.2 MB/s
>> read remote nfsv3:    21.8 MB/s
>> read loopback nfsv4:  25.4 MB/s
>> read remote nfsv4:    21.4 MB/s
> 
> I used the exact same options you are using, and here is the results
> averaged across 3 runs:
> 
> Write local disk      58.5 MB/s
> Write loopback nfsv3: 29.42 MB/s (50% drop)
> 
> Reading (file created from /dev/urandom, somehow I am getting in GB/sec
>             while your results were comparable to write's):

Apparently the file is cached.  You needed to restart nfs
and remount the file system to make sure it isn't before reading it.
Or, you can create a file larger than your host's cache size so
when you write (or read) it sequentially, its tail evicts its head
out of the cache.  This is a less reliable method, yet creating a
file about 25% larger than the host's memory size should work for you.

Benny

>       Read local disk:      2.77 GB/s
>       Read loopback nfsv3:  2.86 GB/s (higher for some reason)
> 
> Thanks,
> 
> - KK
> 

