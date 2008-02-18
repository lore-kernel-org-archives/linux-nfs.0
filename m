From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Performance question
Date: Mon, 18 Feb 2008 11:59:14 -0500
Message-ID: <06EE0C0B-F8AB-4ACA-9314-DF53F2B37E0D@oracle.com>
References: <90d010000802140740y3ff2706ybc169728fbafbfb4@mail.gmail.com> <42996ba90802140827p533779c6o8ab404400be51fdc@mail.gmail.com> <80E378BD-86F7-4009-832A-2978A6FB4600@oracle.com> <90d010000802150737x2ad0739dmeaaa24dc2845e81a@mail.gmail.com> <1203092030.11333.4.camel@heimdal.trondhjem.org> <90d010000802180139x49ac1f49x976f11cec0e01fdf@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"NFS list" <linux-nfs@vger.kernel.org>,
	"Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
To: "Font Bella" <fontbella@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:25527 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753AbYBRQ76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 11:59:58 -0500
In-Reply-To: <90d010000802180139x49ac1f49x976f11cec0e01fdf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 18, 2008, at 4:39 AM, Font Bella wrote:
> I tried TCP and async options, but I get poor performance in my
> benchmarks (a dbench run with 10 clients). Below I tabulated the
> outcome of my tests, which show that in my setting there is a huge
> difference between sync and async, and udp/tcp. Any
> comments/suggestions are warmly welcome.
>
> I also tried setting 128 server threads as Chuck suggested, but this
> doesn't seem to affect performance. This makes sense, since we only
> have a dozen of clients.

Each Linux client mount point can generate up to 16 server requests  
by default.  A dozen clients each with a single mount point can  
generate 192 concurrent requests.  So 128 server threads is not as  
outlandish as you might think.

In this case, you are likely hitting some other bottleneck before the  
clients can utilize all the server threads.

> About sync/async, I am not very concerned about corrupt data if the
> cluster goes down, we do mostly computing, no crucial database
> transactions or anything like that. Our users wouldn't mind some
> degree of data corruption in case of power failure, but speed is
> crucial.

The data corruption is silent.  If it weren't, you could simply  
restore from a backup as soon as you recover from a server crash.   
Silent corruption spreads into your backed up data, and starts  
causing strange application errors, sometimes a long time after the  
corruption first occurred.

> Our network setting is just a dozen of servers connected to a switch.
> Everything (adapters/cables/switch) is 1gigabit. We use ethernet
> bonding to double networking speed.
>
> Here are the test results. I didn't measure SYNC+UDP, since SYNC+TCP
> already gives me very poor performance. Admittedly, my test is very
> simple, and I should probably try something more complete, like
> IOzone. But the dbench run seems to reproduce the bottleneck we've
> been observing in our cluster.

I assume the dbench test is read and write only (little or no  
metadata activity like file creation and deletion).  How closely does  
dbench reflect your production workload?

I see from your initial e-mail that your server file system is:

 > SAS 10k disks.
 >
 > Filesystem: ext3 over LVM.

Have you tried testing over NFS with a file system that resides on a  
single physical disk?  If you have done a read-only test versus a  
write-only test, how do the numbers compare?  Have you tested a range  
of write sizes, from small file writes v. writes to writing files  
larger than the server's memory?

> ********************** ASYNC option in server  
> ******************************
>
> rsize,wsize          TCP                 UDP
>
> 1024                  24 MB/s            34 MB/s
> 2048                  35                 49
> 4096                  37                 75
> 8192                  40.4               35
> 16386                 40.2               19

As the size of the read and write requests increase, your UDP  
throughput decreases markedly.  This does indicate some packet loss,  
so TCP is going to provide consistent performance and much lower risk  
to data integrity as your network and client workloads increase.

You might try this test again and watch your clients' ethernet  
bandwidth and RPC retransmit rate to see what I mean.  At the 16386  
setting, the UDP test may be pumping significantly more packets onto  
the network, but is getting only about 20MB/s through.  This will  
certainly have some effect on other traffic on the network.

The first thing I check in these instances is that gigabit ethernet  
flow control is enabled in both directions on all interfaces (both  
host and switch).

In addition, using larger r/wsize settings on your clients means the  
server can perform disk reads and writes more efficiently, which will  
help your server scale with increasing client workloads.

By examining your current network carefully, you might be able to  
boost the performance of NFS over both UDP and TCP.  With bonded  
gigabit, you should be able to push network throughput past 200 MB/s  
using a test like iPerf which doesn't touch disks.  Thus, at least  
NFS reads from files already in the server's page cache ought to fly  
in this configuration.

> ********************** SYNC option in server  
> ******************************
>
> rsize,wsize          TCP                 UDP
>
> 1024                  6 MB/s             ?? MB/s
> 2048                  7.44               ??
> 4096                  7.33               ??
> 8192                  7                  ??
> 16386                 7                  ??

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
