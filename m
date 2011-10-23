Return-Path: linux-nfs-owner@vger.kernel.org
Received: from snippy.nobiscuit.com ([50.17.199.227]:59046 "EHLO
	snippy.nobiscuit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab1JWEEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Oct 2011 00:04:07 -0400
Received: from oobie.home.nobiscuit.com (124-170-16-165.dyn.iinet.net.au [124.170.16.165])
	by snippy.nobiscuit.com (Postfix) with ESMTPSA id 98FB1A38DE
	for <linux-nfs@vger.kernel.org>; Sun, 23 Oct 2011 03:55:53 +0000 (UTC)
Message-ID: <4EA39046.6020207@nobiscuit.com>
Date: Sun, 23 Oct 2011 14:55:50 +1100
From: Nigel Roberts <nigel@nobiscuit.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 server on ARM
References: <20110529132515.GB19451@snippy.nobiscuit.com>
In-Reply-To: <20110529132515.GB19451@snippy.nobiscuit.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/29/2011 11:25 PM, Nigel Roberts wrote:
> I've run into a problem with running an nfsv4 server on a Marvell
> Kirkwood (armv5tel) platform. When copying a large file (>1GB) to
> the NFS  server, thewrite speed will suddenly slow down to ~750kB/s
> and the CPU wait will jump to 100% for the remainder of the transfer.

I've been doing some large file transfers recently and I've run into 
another similar problem, but this time it's system CPU instead of I/O 
wait. I've done some more testing and I've found the following:

* Seems to only affect nfsv4, I can't reproduce it with nfsv3
* It appears to be triggered when free memory is low i.e. the file size 
is large enough to cause cache memory to reach its maximum.
* Happens with both SLAB and SLUB
* Happens with sec=krb5, krb5i and krb5p
* If I transfer a file that's small enough to fit into free memory, the 
problem doesn't occur.

Here are the exports on the server (Debian squeeze + 3.0.7 kernel + 
latest nfs packages from testing on an iomega ix2-200 marvell kirkwood 
system)

/var/store/exports/backups 
*(sec=krb5:krb5i:krb5p,rw,nohide,sync,no_subtree_check)
/var/store/exports/backups 
oobie.home.nobiscuit.com(rw,async,no_subtree_check)

Here are the fstab entries on the client (Ubuntu Oneric, x86_64)

blue.home.nobiscuit.com:/var/store/exports/backups 
/test/backup-nfs3	nfs	rw,proto=tcp,user,noauto	0	0
blue.home.nobiscuit.com:/backups	/test/backup-nfs4	nfs4 
rw,proto=tcp,user,noauto,sec=krb5	0	0


Here's what a an nfsv3 transfer looks like in vmstat (vmstat 2 with swap 
information removed)

procs -----------memory---------- -----io---- -system-- ----cpu----
  r  b   swpd   free   buff  cache    bi    bo   in   cs us sy id wa
  0  0   1940   4068   8516 214252    0     0   32   10  0  0 100  0
  0  0   1940   4068   8516 214252    0     0   32   11  0  0 100  0
  0  0   1940   4068   8516 214252    0     0   32    9  0  0 100  0
<transfer starts here>
  2  0   1940 204348   8516  16588    0   194 2139 2951  0 34 66  0
  0  0   1940 190824   8516  29988    0  7522 3835 5188  0 42 59  0
  1  0   1940 176148   8528  44644    0  5957 4266 5394  0 50 49  2
  2  0   1940 163248   8532  57588    0  4095 3832 5006  0 34 66  0
  1  0   1940 149456   8536  71308    0  5388 3972 5117  0 39 62  0
  2  0   1940 137104   8544  83404    0 10068 3642 4624  0 42 56  3
  4  0   1940 127336   8544  92364    0  5761 2737 3796  0 32 68  0
  1  0   1940 112804   8552 107308    0  2393 4314 5613  0 42 58  1
  0  0   1940  98284   8552 121612    0  8698 4131 5324  0 40 60  0
  2  0   1940  84604   8552 135116    0  5316 4017 5192  0 48 52  0
  0  0   1940  72244   8560 147308    0  8186 3523 4625  0 42 57  2
  0  0   1940  59944   8560 159340    0  8860 3564 4602  0 41 59  0
  1  0   1940  46684   8568 172396    0  2064 3824 5040  0 37 62  1
  1  0   1940  33784   8568 185132    0  7026 3506 4612  0 37 63  0
  1  0   1940  20824   8572 197876    0  9442 3780 4862  0 39 62  0
  1  0   1940   7264   8580 211220    0  5844 3882 5133  0 42 57  2
  0  0   1940   2704   8448 215824    0  4098 4271 5392  0 47 54  0
  0  0   1940   2688   8452 215680    0  8450 4109 5123  1 47 50  3
  0  0   1940   3064   8444 215276    0  7300 3787 4909  0 34 66  0
  0  0   1940   3116   8444 215212    0  8850 3488 4524  0 37 63  0
  1  0   1940   2688   8456 215564    0  8815 3982 4924  0 41 58  2
  0  0   1940   2980   8448 215488    0     1 4101 5408  0 44 57  0
  3  0   1940   3688   8456 214108    0  9047 3783 4880  0 44 55  2
  1  0   1940   2816   8448 215636    0  8867 3285 4452  0 35 66  0
...
The transfer continues to the end with neither a sudden jump in the sy 
number nor any drop in bo.

Here is a transfer with the same file to the same location, using nfsv4 
with sec=krb5:

procs -----------memory---------- -----io---- -system-- ----cpu----
  r  b   swpd   free   buff  cache    bi    bo   in   cs us sy id wa
  0  0   1940   3072   8432 215320    0     0   32   11  0  0 100  0
  0  0   1940   3072   8432 215320    0     0   31   10  0  0 100  0
  0  0   1940   3072   8432 215320    0     0   31   10  0  0 100  0
<transfer starts here>
  0  0   1940   3072   8440 215344    6    20   75  101  0  1 97  3
  0  0   1940   3072   8456 215344    0    20  125  172  1  1 93  5
  0  0   1940 203404   8476  17556    0    50 2394 3514  0 44 52  5
  1  0   1940 191316   8480  29216    0  9299 3333 4694  0 39 61  0
  2  0   1940 179876   8496  40952    0    26 3382 4837  0 42 56  1
  1  0   1940 167472   8496  53364    0  6605 3514 5091  0 37 63  0
  0  0   1940 155892   8496  64948    0  5128 3249 4691  0 37 63  0
  1  0   1940 144312   8504  76372    0  4664 3182 4652  0 38 61  2
  1  0   1940 130856   8504  89588    0  6760 3694 5102  0 44 57  0
  2  0   1940 115272   8516 104988    0  6519 4308 5937  0 50 49  2
  2  0   1940 100752   8516 119220    0  5052 4062 5498  0 48 53  0
  1  0   1940  85512   8516 134236    0  6425 4144 5791  0 49 51  0
  0  0   1940  72192   8524 147388    0  4962 3629 5177  0 40 57  4
  2  0   1940  59532   8524 159708    0  4928 3439 5080  0 33 68  0
  2  0   1940  47652   8532 171452    0 15865 3290 4709  0 47 51  3
  2  0   1940  33372   8532 185500    0  6142 3874 5541  0 47 54  0
  3  0   1940  19632   8532 199036    0  6709 3793 5270  0 45 56  0
  2  0   1940   6956   8540 211520    0  6598 3556 4900  0 40 58  2
  2  0   1940   3132   8408 215328    0  4092 3494 5157  0 39 61  0
<sudden drop in performance here>
  2  1   1940   2796   8540 215364    0  9439 1021 1191  0 92  9  0
  1  1   1940   3096   8724 214612    0   740  429  486  0 100  0  0
  1  1   1940   3096   8900 214656    0   728  424  471  0 100  0  0
  1  1   1940   2856   9076 214808    0   760  449  477  0 100  0  0
  1  1   1940   2616   9252 214820    0   712  420  466  0 100  0  0
  1  1   1940   3096   9428 214108    0   792  467  490  0 100  0  0
  1  1   1940   2976   9620 214120    0   784  456  498  0 100  0  0
  1  1   1940   2556   9804 214292    0   804  461  495  0 100  0  0
...

The transfer will eventually complete, but obviously it takes much longer.

At the point where free memory reaches its lowest point, note the sudden 
increase in sy and the big drop off in bo. Is it a memory allocation 
problem? I've tried increasing the logging for nfsd but there's nothing 
obvious that I can see.

Are there some other statistics I should be looking at? I've tried to 
get ftrace working but I haven't had any luck yet (the ftrace tests fail 
on boot).

Regards,
Nigel
