Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57125 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab0HaQXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 12:23:30 -0400
Date: Tue, 31 Aug 2010 12:23:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Peng Yu <pengyu.ut@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 30 time speed difference between using NFS and without using
 NFS
Message-ID: <20100831162304.GE3071@fieldses.org>
References: <AANLkTimog6uTdsxzFeA0YY+HK6gtcwEGXaFDJs+Aorm0@mail.gmail.com>
 <20100830170923.GA17103@fieldses.org>
 <AANLkTinEPVpnKCzZS5fBhhGj9Xmh8H-758SdEJSuxZ=8@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTinEPVpnKCzZS5fBhhGj9Xmh8H-758SdEJSuxZ=8@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 04:39:54PM -0500, Peng Yu wrote:
> Please see below for the answers of you questions.
> 
> $ find . -type d|wc
>    1491    1491   53372
> 
> Search the directory as a local directory
> 
> $ time find . -name 'data.frame' -type d
> ./library/base/data.frame
> ./library/base/data.frame/data.frame
> 
> real	0m0.044s
> user	0m0.012s
> sys	0m0.028s
> 
> Search the directory as a NFS directory. The same command runs three 3
> times in series.
> 
> $ time find . -name 'data.frame' -type d
> ./library/base/data.frame
> ./library/base/data.frame/data.frame
> 
> real	0m2.205s
> user	0m0.040s
> sys	0m0.430s
> $ time find . -name 'data.frame' -type d
> ./library/base/data.frame
> ./library/base/data.frame/data.frame
> 
> real	0m1.203s
> user	0m0.060s
> sys	0m0.120s
> $ time find . -name 'data.frame' -type d
> ./library/base/data.frame
> ./library/base/data.frame/data.frame
> 
> real	0m1.227s
> user	0m0.040s
> sys	0m0.200s
> 
> Ping the NFS server gives me ttl=64 time=0.156 ms.

So if readding each of those directories required only a single round
trip, and if network round trip time were the dominating factor, the
whole thing would only take a second.  So there may be more rpc's (is
find also stat'ing every directory entry?), and/or you may be
bottlenecked by somethign else (e.g. seek time on the server).

You might try using /proc/self/mounstats on the client to figure out
what rpc's are sent during the find and the average time they take.

--b.
