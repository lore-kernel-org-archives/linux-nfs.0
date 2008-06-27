From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Fri, 27 Jun 2008 11:06:28 -0700
Message-ID: <48652C24.6030409@gmail.com>
References: <OF3C28594A.91157CD9-ON65257475.0029EEE9-65257475.0031D7A5@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:1983 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763368AbYF0SGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jun 2008 14:06:44 -0400
Received: by yw-out-2324.google.com with SMTP id 9so232602ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Jun 2008 11:06:34 -0700 (PDT)
In-Reply-To: <OF3C28594A.91157CD9-ON65257475.0029EEE9-65257475.0031D7A5@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One option might be to try using O_DIRECT if you are worried about 
memory (although I would read/write in at least 1 MB at a time).  I 
would expect this to help at least a bit especially on reads.

Also, check all the standard nfs tuning stuff, #nfsds, #rpc slots.  
Since with a loopback you effectively have no latency, you would want to 
ensure that neither the #nfsds or #rpc slots is a bottleneck (if either 
one is too low, you will have a problem).  One way to reduce the # of 
requests and therefore require fewer nfsds/rpc_slots is to 'cat 
/proc/mounts' to see your wsize/rsize.  Ensure your wsize/rsize is a 
decent size (~ 1MB).

Dean

Krishna Kumar2 wrote:
> Chuck Lever <chuck.lever@oracle.com> wrote on 06/26/2008 11:12:58 PM:
>
>   
>>> Local:
>>>      Read:  69.5 MB/s
>>>      Write: 70.0 MB/s
>>> NFS of same FS mounted loopback on same system:
>>>      Read:  29.5 MB/s  (57% drop)
>>>      Write: 27.5 MB/s  (60% drop)
>>>       
>> You can look at client-side NFS and RPC performance metrics using some
>> prototype Python tools that were just added to nfs-utils.  The scripts
>> themselves can be downloaded from:
>>     http://oss.oracle.com/~cel/Linux-2.6/2.6.25
>> but unfortunately they are not fully documented yet so you will have
>> to approach them with an open mind and a sense of experimentation.
>>
>> You can also capture network traces on your loopback interface to see
>> if there is, for example, unexpected congestion or latency, or if
>> there are other problems.
>>
>> But for loopback, the problem is often that the client and server are
>> sharing the same physical memory for caching data.  Analyzing your
>> test system's physical memory utilization might be revealing.
>>     
>
> But loopback is better than actual network traffic. If my file size is
> less than half the available physical memory, then this should not be
> a problem, right? The server caches the file data (64K at a time), and
> sends to the client (on the same system) and the client has a local
> copy. I am testing today with that assumption.
>
> My system has 4GB memory, of which 3.4GB is free before running the test.
> I created a 1.46GB (so that double that size for server/client copies will
> not be more than 3GB) file by running:
>       dd if=/dev/zero of=smaller_file bs=65536 count=24000
>
> To measure the time exactly for just the I/O part, I have a small program
> that
> reads data in chunks of 64K and discards it "while (read(fd, buf, 64K) >
> 0)",
> with a gettimeofday before and after it to measure bandwidth. For each run,
> the script does (psuedo): "umount /nfs, stop nfs server, umount /local,
> mount /local, start nfs server, and mount /nfs". The result is:
>
> Testing on /local
>       Time: 38.4553     BW:39.01 MB/s
>       Time: 38.3073     BW:39.16 MB/s
>       Time: 38.3807     BW:39.08 MB/s
>       Time: 38.3724     BW:39.09 MB/s
>       Time: 38.3463     BW:39.12 MB/s
> Testing on /nfs
>       Time: 52.4386     BW:28.60 MB/s
>       Time: 50.7531     BW:29.55 MB/s
>       Time: 50.8296     BW:29.51 MB/s
>       Time: 48.2363     BW:31.10 MB/s
>       Time: 51.1992     BW:29.30 MB/s
>
> Average bandwidth drop across 5 runs is 24.24%.
>
> Memory stats *before* and *after* one run for /local and /nfs is:
>
> ********** local.start ******
> MemFree:       3500700 kB
> Cached:         317076 kB
> Inactive:       249356 kB
>
> ********** local.end ********
> MemFree:       1961872 kB
> Cached:        1853100 kB
> Inactive:      1785028 kB
>
> ********** nfs.start ********
> MemFree:       3480456 kB
> Cached:         317072 kB
> Inactive:       252740 kB
>
> ********** nfs.end **********
> MemFree:        400892 kB
> Cached:        3389164 kB
> Inactive:      3324800 kB
>
> I don't know if this is useful but looking at ratios:
> Memfree increased almost 5 times from 1.78 (Memfree before / Memfree after)
> to 8.68 for /local and /nfs respectively. Inactive almost doubled from 7.15
> times to 13.15 times for /local and /nfs (Inactive after / Inactive
> before),
> and Cached also almost doubled from 5.84 times to 10.69 times (same for
> Cached).
>
>   
>> Otherwise, you should always expect some performance degradation when
>> comparing NFS and local disk.  50% is not completely unheard of.  It's
>> the price paid for being able to share your file data concurrently
>> among multiple clients.
>>     
>
> But if the file is being shared only with one client (and that too
> locally),
> isn't 25% too high?
>
> Will I get better results on NFSv4, and should I try delegation (that
> sounds
> automatic and not something that the user has to start)?
>
> Thanks,
>
> - KK
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
