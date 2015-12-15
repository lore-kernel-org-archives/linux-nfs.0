Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22362 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932859AbbLOBe5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 20:34:57 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: Call graph of nfsd_open
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtQ_HS94LGanKMThxxu6K0Ra49q688obTDLFdYuQCDAsow@mail.gmail.com>
Date: Mon, 14 Dec 2015 20:34:50 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C9244556-098E-440E-ABB7-7526BE4909BB@oracle.com>
References: <C4AC976E-608D-4B2D-9835-C444EF0E1325@oracle.com> <CAHQdGtQ_HS94LGanKMThxxu6K0Ra49q688obTDLFdYuQCDAsow@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 3, 2015, at 2:53 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> Hi Chuck,
> 
> On Thu, Dec 3, 2015 at 10:31 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Hi-
>> 
>> I’m looking into NFS WRITE latency on the Linux NFS server.
>> With a high speed network fabric and ultra-fast storage (think
>> persistent memory) we can get the per-WRITE latency under 50us
>> (as observed on the wire at the server).
>> 
>> One source of the remaining latency appears to be nfsd_open.
>> Here is an example of a call graph captured during a simple
>> iozone 4KB direct write workload (v4.4-rc3):

[ ... function call graph snipped ... ]

>> And that’s 20us total for this nfsd_open. Seems like a lot of
>> work for each NFSv3 WRITE operation, and plenty of opportunities
>> for lock contention if my server happened to be otherwise busy.
>> 
>> Note these figures are a little inflated because ftrace itself
>> adds some latency.
>> 
>> Anyway, making fh_verify faster could have a significant
>> impact on per-op latency with fast storage. The recently-proposed
>> NFSD open cache by itself could eliminate the need to perform
>> fh_verify so often, for example.
>> 
> 
> Have you compared with Jeff's patchset? It would be very interesting
> to see how that affects your numbers.

I compared the latency of read(2) and write(2) as measured
by iozone on the client.

I pulled Jeff's patches from samba.org, they are based on
4.4-rc4. My patches are my for-4.5 series, also based on
4.4-rc4. I've disabled FRMR on the server for RDMA Reads.
The share is a tmpfs.

The client is 4.4-rc4 with my for-4.5 patches applied.
1MB rsize and wsize.

The fabric is FDR, both systems have CX-3 Pro adapters
and report 56Gbps link speed.

The test is "iozone -az -i0 -i1 -y1k -s128m -I -N". The
results are microseconds per system call. Lower is
better.

With Jeff's NFSD open cache:

              KB  reclen   write rewrite    read    reread
          131072       1      48      48       43       43
          131072       2      49      49       43       43
          131072       4      50      50       43       43
          131072       8      54      52       45       46
          131072      16      59      58       48       48
          131072      32      71      69       56       56
          131072      64      97      92       75       78
          131072     128     147     142      105      105
          131072     256     237     216      171      162
          131072     512     492     457      268      267
          131072    1024     806     748      529      526
          131072    2048    1257    1189      711      696
          131072    4096    1884    1718     1019     1016
          131072    8192    3452    2958     1714     1710
          131072   16384    6835    5416     3132     3134

With my for-4.5 patches (no open cache):

              KB  reclen   write rewrite    read    reread
          131072       1      49      50       43       43
          131072       2      50      49       43       43
          131072       4      51      50       43       43
          131072       8      55      53       45       45
          131072      16      60      58       48       48
          131072      32      70      68       53       54
          131072      64      91      85       69       69
          131072     128     140     130       95       96
          131072     256     214     203      145      147
          131072     512     480     410      253      249
          131072    1024     755     698      508      477
          131072    2048    1206    1049      667      656
          131072    4096    1786    1632      977      977
          131072    8192    3243    2851     1670     1672
          131072   16384    6579    5276     3091     3092

You can see below 64KB I/O size, Jeff's open cache saves
about a microsecond per NFS WRITE. NFS READ is not affected.

Above that, other effects dominate the cost per I/O. I can't
explain yet why my for-4.5 server looks better with larger I/Os.

NFS WRITE takes longer than NFS READ even with a memory
file system. The difference seems to be dealing with all
the pages: on the server, this is done by the local file
system; on the client, there's a palpable O/S cost per page
to set up memory registration (the FAST_REG WR itself is
quick), and lock contention dealing with the NFS WRITE
completions.

Looking at ways to speed up fh_verify would help the smaller
WRITEs, and reducing the cost of page management might be
good for large I/O.


--
Chuck Lever




