Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69314C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:28:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2701A20868
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:28:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2701A20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725928AbeK3GfU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 01:35:20 -0500
Received: from foss.arm.com ([217.140.101.70]:43870 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725788AbeK3GfT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 01:35:19 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A8FD880D;
        Thu, 29 Nov 2018 11:28:49 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DE7723F73F;
        Thu, 29 Nov 2018 11:28:48 -0800 (PST)
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
To:     Catalin Marinas <catalin.marinas@arm.com>,
        Trond Myklebust <trondmy@gmail.com>
Cc:     linux-nfs@vger.kernel.org
References: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
 <20181109111930.idve77thgcnsg5u3@localhost>
From:   Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
Date:   Thu, 29 Nov 2018 19:28:47 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181109111930.idve77thgcnsg5u3@localhost>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond, Catalin

On 09/11/2018 11:19, Catalin Marinas wrote:
> Hi Trond,
> 
> On Mon, Sep 17, 2018 at 09:03:31AM -0400, Trond Myklebust wrote:
>> Most of this code should also be reusable with other socket types.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>> ---
>>  include/linux/sunrpc/xprtsock.h |  19 +-
>>  include/trace/events/sunrpc.h   |  15 +-
>>  net/sunrpc/xprtsock.c           | 694 +++++++++++++++-----------------
>>  3 files changed, 335 insertions(+), 393 deletions(-)
> 
> With latest mainline (24ccea7e102d, it includes Al Viro's iov_iter
> fixup) I started hitting some severe slowdown and systemd timeouts with
> nfsroot on arm64 machines (physical or guests under KVM). Interestingly,
> it only happens when the client kernel is configured with 64K pages, the
> 4K pages configuration runs fine. It also runs fine if I add rsize=65536
> to the nfsroot= argument.
> 
> Bisecting led me to commit 277e4ab7d530 ("SUNRPC: Simplify TCP receive
> code by switching to using iterators"). Prior to this commit, it works
> fine.
> 
> Some more info:
> 
> - defconfig with CONFIG_ARM64_64K_PAGES enabled
> 
> - kernel cmdline arg: nfsroot=<some-server>:/srv/nfs/debian-arm64,tcp,v4
> 
> - if it matters, the server is also an arm64 machine running 4.19 with
>   4K pages configuration
> 
> I haven't figured out what's wrong or even how to debug this as I'm not
> familiar with the sunrpc code. Any suggestion?
> 
> Thanks.
> 

I've done a bit of experiments/observations with this since it was seriously
impacting all form of testing on arm64 with a 64K pages configuration.

I can confirm rsize=65536 workaround above mentioned by Catalin is effective
also for me, as it is to reset back before the commit mentioned in the subject.

In the following I tested instead with:

- linus arm64 v4.20-rc1 64K pages
  + "Debug Lockups and Hangs" Enabled
- hw Juno-r2
- fully NFS mounted rootfs (Debian 9)
- NO rsize workaround
- NFS Client config(nfsstat -m)
Flags:
rw,relatime,vers=4.0,rsize=4096,wsize=4096,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.1,local_lock=none,addr=192.168.0.254

Observations:

1. despite some general boot slow down (not so evident in my setup), I hit the
issue when simply trying to launch LTP or LKP tests (all is in NFS mounted
rootfs): the immediately observable behavior is just that the application gets
'apparently' stuck straight away (NO output whatsoever). Waiting some seconds
yields no progress or result NOR any Lockup is detected by Kernel. A good deal
of effort is needed to kill the process at this point...BUT it is feasible (many
SIGSTOP + KILL)...and the system is back alive.


2. running again LKP via 'strace' we can observe the process apparently starting
fine but then suddenly hanging randomly multiple times: at first on an execve()
and then on some read() while trying to load its own file components; each hang
lasts 30-45 seconds approximately.

In LKP as an example:

$ strace lkp run ./dbench-100%.yaml

....
newfstatat(AT_FDCWD, "/opt/lkp-tests/bin/run-local", {st_mode=S_IFREG|0755,
st_size=4367, ...}, 0) = 0
faccessat(AT_FDCWD, "/opt/lkp-tests/bin/run-local", X_OK) = 0
execve("/opt/lkp-tests/bin/run-local", ["/opt/lkp-tests/bin/run-local",
"./dbench-100%.yaml"], [/* 12 vars */]                            <<< HANGGG
...
...
30-40 secs..
....
openat(AT_FDCWD, "/usr/lib/ruby/2.3.0/rubygems.rb",
O_RDONLY|O_NONBLOCK|O_CLOEXEC) = 7
fstat(7, {st_mode=S_IFREG|0644, st_size=33018, ...}) = 0
close(7)                                = 0
getuid()                                = 0
geteuid()                               = 0
getgid()                                = 0
getegid()                               = 0
oopenat(AT_FDCWD, "/usr/lib/ruby/2.3.0/rubygems.rb",
O_RDONLY|O_NONBLOCK|O_CLOEXEC) = 7
fcntl(7, F_SETFL, O_RDONLY)             = 0
fstat(7, {st_mode=S_IFREG|0644, st_size=33018, ...}) = 0
fstat(7, {st_mode=S_IFREG|0644, st_size=33018, ...}) = 0
ioctl(7, TCGETS, 0xffffdd0895d8)        = -1 ENOTTY (Inappropriate ioctl for device)
read(7, <<<HANGGSSS

....
~30-40 secs
....

"# frozen_string_literal: true\n# "..., 8192) = 8192
read(7, ") as the standard configuration "..., 8192) = 8192
brk(0xaaaaeea70000)                     = 0xaaaaeea70000
read(7, "ady been required, then we have "..., 8192) = 8192
read(7, "lf.user_home\n    @user_home ||= "..., 8192) = 8192
read(7, "    require \"rubygems/defaults/#"..., 8192) = 250
read(7, "", 8192)                       = 0
close(7)                                = 0
....
....

openat(AT_FDCWD, "/usr/lib/ruby/2.3.0/rubygems/specification.rb",
O_RDONLY|O_NONBLOCK|O_CLOEXEC) = 7
fstat(7, {st_mode=S_IFREG|0644, st_size=81998, ...}) = 0
close(7)                                = 0
getuid()                                = 0
geteuid()                               = 0
getgid()                                = 0
getegid()                               = 0
openat(AT_FDCWD, "/usr/lib/ruby/2.3.0/rubygems/specification.rb",
O_RDONLY|O_NONBLOCK|O_CLOEXEC) = 7
fcntl(7, F_SETFL, O_RDONLY)             = 0
fstat(7, {st_mode=S_IFREG|0644, st_size=81998, ...}) = 0
fstat(7, {st_mode=S_IFREG|0644, st_size=81998, ...}) = 0
ioctl(7, TCGETS, 0xffffef390b38)        = -1 ENOTTY (Inappropriate ioctl for device)
read(7, "# -*- coding: utf-8 -*-\n# frozen"..., 8192) = 8192
read(7, "e platform attribute appropriate"..., 8192) = 8192
read(7, "sealicense.com/.\n  #\n  # You sho"..., 8192) = 8192
read(7, " TODO: find all extraneous adds\n"..., 8192) = 8192
read(7, "rn a list of all outdated local "..., 8192) = 8192
read(7, "          = authors.collect { |a"..., 8192) = 8192
read(7, "ends on.\n  #\n  # Use #add_depend"..., 8192) = 8192
read(7, "ns true you\n  # probably want to"..., 8192) = 8192
read(7,  <<<< HANGGGGG

Note that this last hang happens halfway through a file read !


3. Having a look at the underlying network traffic with Wireshark I could see in
fact that the NFS packets stop flowing completely for 30-40s when all of the
above happens...but I cannot see any error or timeout or NFS retries.
Same happened when I tried to reduce NFS timeo to 150 (15secs) from the original
600 (60 secs). This lack of retries was confirmed by stats:
root@sqwt-ubuntu:/opt/lkp-tests# nfsstat -r
Client rpc stats:
calls      retrans    authrefrsh
16008      0          16019

The only notable thing is a routine TCP KeepAlive sent by the NFS Client TCP
stack during the 30/40 secs quiet window: NFS data flow restarts anyway after
another 10/12 secs after the KeepAlive is sent and ACKed by the server, so it
does not seem the trigger itself for the restart.


4. Waiting forever (minutes) I was finally be able to see LKP completing
initialization and the dbench test being run. Below you can see the results with
and without the rsize workaround:

DBENCH SANE RESULTS WITH WORKAROUND RSIZE=65536
------------------------------------------------
...
   6    122759     5.62 MB/sec  execute 599 sec  latency 84.304 ms
   6  cleanup 600 sec
   0  cleanup 600 sec

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX     108397    11.100   358.921
 Close          79762    16.243   406.213
 Rename          4582    19.399   259.180
 Unlink         21728     3.610   190.564
 Qpathinfo      98367     1.773   289.554
 Qfileinfo      17163     9.917   232.687
 Qfsinfo        17903     2.130   216.804
 Sfileinfo       8828    17.427   234.069
 Find           37915     3.478   287.326
 WriteX         53503     0.048     2.992
 ReadX         169707     0.592   199.341
 LockX            350    13.536   242.800
 UnlockX          350     2.801   124.317
 Flush           7548    20.248   229.864

Throughput 5.61504 MB/sec  6 clients  6 procs  max_latency=406.225 ms


DBENCH RESULTS WITHOUT WORKAROUND
---------------------------------
...
  6    111273     5.06 MB/sec  execute 599 sec  latency 4066.072 ms
   6  cleanup 600 sec
   3  cleanup 601 sec
   0  cleanup 601 sec

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX      97674    12.244 13773.786
 Close          71583    19.126 13774.836
 Rename          4135    19.177   277.171
 Unlink         19881     4.286 12842.441
 Qpathinfo      88303     1.942 12923.151
 Qfileinfo      15305     9.636   203.481
 Qfsinfo        16305     1.801   227.405
 Sfileinfo       7960    15.871   186.799
 Find           34164     3.409   255.098
 WriteX         48105     0.053     5.428
 ReadX         152460     0.926 13759.913
 LockX            314     7.562    53.131
 UnlockX          314     1.847    47.083
 Flush           6872    19.222   200.180

Throughput 5.06232 MB/sec  6 clients  6 procs  max_latency=13774.850 ms

Then I tried to running also:

./nfstest_io -d /mnt/t/data -v all -n 10 -r 3600

with WORKAROUND it took:
INFO: 2018-11-28 16:31:25.031280  TIME:        449 secs

WITHOUT:
INFO: 2018-11-28 17:55:39.438688  TIME:       1348 secs


4. All of the above 'slowliness' disappeared when I re-run the same tests the
second time, since NFS had cached all locally in the first run probably.


5. Reboot hangs similarly.


The fact that the traffic stops without triggering any NFS timeo and retry makes
me thing that are the egressing NFS rpc requests themselves that got stuck
somehow (but I'm far from being an NFS expert)

Any idea or thoughts ? Additional sensible test cases to run ?
Or hint on where to look inside NFS code Trond ?
(I'll re-test with a newer 4.20 RC and trying to ftrace something...in the next
days)

Thanks

Cristian







