Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38860 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab0H3Vj4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 17:39:56 -0400
Received: by wyb35 with SMTP id 35so7093057wyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 30 Aug 2010 14:39:54 -0700 (PDT)
In-Reply-To: <20100830170923.GA17103@fieldses.org>
References: <AANLkTimog6uTdsxzFeA0YY+HK6gtcwEGXaFDJs+Aorm0@mail.gmail.com>
	<20100830170923.GA17103@fieldses.org>
Date: Mon, 30 Aug 2010 16:39:54 -0500
Message-ID: <AANLkTinEPVpnKCzZS5fBhhGj9Xmh8H-758SdEJSuxZ=8@mail.gmail.com>
Subject: Re: 30 time speed difference between using NFS and without using NFS
From: Peng Yu <pengyu.ut@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 12:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Aug 27, 2010 at 06:08:25PM -0500, Peng Yu wrote:
>> Hi,
>>
>> I use the following command to search for some directory.
>>
>> find -L some_dir -type d -name some_name
>>
>> If I'm on the machine that has some_dir locally, the run time is
>> real  0m0.199s
>> user  0m0.048s
>> sys   0m0.140s
>>
>> If I'm on another machine that sees the same directory by NFS (NFS3).
>> the run time is
>> real  0m6.509s
>> user  0m0.090s
>> sys   0m1.380s
>>
>> There are 30 time speed difference. Is this normal? Is there any NFS
>> parameter that I should tune to make the latter faster?
>
> How many directories are there in some_dir?  What's the round trip time
> (e.g. as reported by ping) to the server?  If you repeate the find
> immediately, is it faster?
>
> This can indeed by much slower if it requires revalidating the cached
> attributes of each file.

Please see below for the answers of you questions.

$ find . -type d|wc
   1491    1491   53372

Search the directory as a local directory

$ time find . -name 'data.frame' -type d
./library/base/data.frame
./library/base/data.frame/data.frame

real	0m0.044s
user	0m0.012s
sys	0m0.028s

Search the directory as a NFS directory. The same command runs three 3
times in series.

$ time find . -name 'data.frame' -type d
./library/base/data.frame
./library/base/data.frame/data.frame

real	0m2.205s
user	0m0.040s
sys	0m0.430s
$ time find . -name 'data.frame' -type d
./library/base/data.frame
./library/base/data.frame/data.frame

real	0m1.203s
user	0m0.060s
sys	0m0.120s
$ time find . -name 'data.frame' -type d
./library/base/data.frame
./library/base/data.frame/data.frame

real	0m1.227s
user	0m0.040s
sys	0m0.200s

Ping the NFS server gives me ttl=64 time=0.156 ms.

Please let me know if there is more information needed.

-- 
Regards,
Peng
