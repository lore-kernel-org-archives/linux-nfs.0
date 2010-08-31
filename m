Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62013 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab0HaV1h convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 17:27:37 -0400
Received: by wyb35 with SMTP id 35so8364872wyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 Aug 2010 14:27:35 -0700 (PDT)
In-Reply-To: <20100831162304.GE3071@fieldses.org>
References: <AANLkTimog6uTdsxzFeA0YY+HK6gtcwEGXaFDJs+Aorm0@mail.gmail.com>
	<20100830170923.GA17103@fieldses.org>
	<AANLkTinEPVpnKCzZS5fBhhGj9Xmh8H-758SdEJSuxZ=8@mail.gmail.com>
	<20100831162304.GE3071@fieldses.org>
Date: Tue, 31 Aug 2010 16:27:35 -0500
Message-ID: <AANLkTikGx4SeY1RBQ4_SbcAwd02bCTtQ_0Sz+Pzs+sbU@mail.gmail.com>
Subject: Re: 30 time speed difference between using NFS and without using NFS
From: Peng Yu <pengyu.ut@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 31, 2010 at 11:23 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Aug 30, 2010 at 04:39:54PM -0500, Peng Yu wrote:
>> Please see below for the answers of you questions.
>>
>> $ find . -type d|wc
>>    1491    1491   53372
>>
>> Search the directory as a local directory
>>
>> $ time find . -name 'data.frame' -type d
>> ./library/base/data.frame
>> ./library/base/data.frame/data.frame
>>
>> real  0m0.044s
>> user  0m0.012s
>> sys   0m0.028s
>>
>> Search the directory as a NFS directory. The same command runs three 3
>> times in series.
>>
>> $ time find . -name 'data.frame' -type d
>> ./library/base/data.frame
>> ./library/base/data.frame/data.frame
>>
>> real  0m2.205s
>> user  0m0.040s
>> sys   0m0.430s
>> $ time find . -name 'data.frame' -type d
>> ./library/base/data.frame
>> ./library/base/data.frame/data.frame
>>
>> real  0m1.203s
>> user  0m0.060s
>> sys   0m0.120s
>> $ time find . -name 'data.frame' -type d
>> ./library/base/data.frame
>> ./library/base/data.frame/data.frame
>>
>> real  0m1.227s
>> user  0m0.040s
>> sys   0m0.200s
>>
>> Ping the NFS server gives me ttl=64 time=0.156 ms.
>
> So if readding each of those directories required only a single round
> trip, and if network round trip time were the dominating factor, the
> whole thing would only take a second.  So there may be more rpc's (is
> find also stat'ing every directory entry?), and/or you may be
> bottlenecked by somethign else (e.g. seek time on the server).
>
> You might try using /proc/self/mounstats on the client to figure out
> what rpc's are sent during the find and the average time they take.

Hi,

I don't really know how to read /proc/self/mounstats

But here is the corresponding record in it on the client machine
before and after I run the find command once. Are you able to tell
what is wrong?

#######before

device xx.xx.x.xx:/pearson/data mounted on /pearson/data with fstype
nfs statvers=1.0
	opts:	rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.16.4.20,mountvers=3,mountport=0,mountproto=tcp
	age:	167462
	caps:	caps=0x3fcf,wtmult=4096,dtsize=4096,bsize=0,namlen=255
	sec:	flavor=1,pseudoflavor=1
	events:	97266 2937027 45 379 43366 10794 3030879 707 3 239 553 71267
53078 256 331 248 0 3941 0 1 209 0 0 0 0
	bytes:	3620495167 2489192 0 0 29243366 1919994 7293 553
	RPC iostats version: 1.0  p/v: 100003/3 (nfs)
	xprt:	tcp 870 1 6 0 11 144892 144890 2 323286 727
	per-op statistics
	        NULL: 0 0 0 0 0 0 0 0
	     GETATTR: 97268 97268 0 17511024 10894016 300 27490 34980
	     SETATTR: 428 428 0 92916 61632 0 1000 1030
	      LOOKUP: 11128 11128 0 2158020 1509208 30 5010 5640
	      ACCESS: 28926 28926 0 5210656 3471000 110 8000 9950
.........


#######After

device xx.xx.x.xx:/pearson/data mounted on /pearson/data with fstype
nfs statvers=1.0
	opts:	rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.16.4.20,mountvers=3,mountport=0,mountproto=tcp
	age:	167478
	caps:	caps=0x3fcf,wtmult=4096,dtsize=4096,bsize=0,namlen=255
	sec:	flavor=1,pseudoflavor=1
	events:	101739 2943313 45 379 46349 10794 3043133 707 3 239 553 71267
56060 256 331 248 0 3941 0 1 209 0 0 0 0
	bytes:	3620495167 2489192 0 0 29243366 1919994 7293 553
	RPC iostats version: 1.0  p/v: 100003/3 (nfs)
	xprt:	tcp 870 1 6 0 3 150855 150853 2 341175 727
	per-op statistics
	        NULL: 0 0 0 0 0 0 0 0
	     GETATTR: 101741 101741 0 18298272 11394992 310 28740 36660
	     SETATTR: 428 428 0 92916 61632 0 1000 1030
	      LOOKUP: 11128 11128 0 2158020 1509208 30 5010 5640
	      ACCESS: 30416 30416 0 5478856 3649800 110 8290 10360
.......


-- 
Regards,
Peng
