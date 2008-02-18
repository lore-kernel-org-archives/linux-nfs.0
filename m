From: "Font Bella" <fontbella@gmail.com>
Subject: Re: Performance question
Date: Mon, 18 Feb 2008 10:39:46 +0100
Message-ID: <90d010000802180139x49ac1f49x976f11cec0e01fdf@mail.gmail.com>
References: <90d010000802140740y3ff2706ybc169728fbafbfb4@mail.gmail.com>
	 <42996ba90802140827p533779c6o8ab404400be51fdc@mail.gmail.com>
	 <80E378BD-86F7-4009-832A-2978A6FB4600@oracle.com>
	 <90d010000802150737x2ad0739dmeaaa24dc2845e81a@mail.gmail.com>
	 <1203092030.11333.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
	"NFS list" <linux-nfs@vger.kernel.org>,
	"Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:9856 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbYBRJjs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 04:39:48 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1420978fga.17
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 01:39:47 -0800 (PST)
In-Reply-To: <1203092030.11333.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I tried TCP and async options, but I get poor performance in my
benchmarks (a dbench run with 10 clients). Below I tabulated the
outcome of my tests, which show that in my setting there is a huge
difference between sync and async, and udp/tcp. Any
comments/suggestions are warmly welcome.

I also tried setting 128 server threads as Chuck suggested, but this
doesn't seem to affect performance. This makes sense, since we only
have a dozen of clients.

About sync/async, I am not very concerned about corrupt data if the
cluster goes down, we do mostly computing, no crucial database
transactions or anything like that. Our users wouldn't mind some
degree of data corruption in case of power failure, but speed is
crucial.

Our network setting is just a dozen of servers connected to a switch.
Everything (adapters/cables/switch) is 1gigabit. We use ethernet
bonding to double networking speed.

Here are the test results. I didn't measure SYNC+UDP, since SYNC+TCP
already gives me very poor performance. Admittedly, my test is very
simple, and I should probably try something more complete, like
IOzone. But the dbench run seems to reproduce the bottleneck we've
been observing in our cluster.

Thanks,
/P


********************** ASYNC option in server ******************************

rsize,wsize          TCP                 UDP

1024                  24 MB/s            34 MB/s
2048                  35                 49
4096                  37                 75
8192                  40.4               35
16386                 40.2               19

********************** SYNC option in server ******************************

rsize,wsize          TCP                 UDP

1024                  6 MB/s             ?? MB/s
2048                  7.44               ??
4096                  7.33               ??
8192                  7                  ??
16386                 7                  ??

On Feb 15, 2008 5:13 PM, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> That very likely implies that you have problems with UDP packet loss.
> Switch to TCP.
>
> Trond
>
>
