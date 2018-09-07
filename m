Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:35880 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728557AbeIGU0O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2018 16:26:14 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 0/7] Misc NFS + pNFS performance enhancements
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <73fe659b96e30e1c1542352be32867a6fb7caa08.camel@hammerspace.com>
Date: Fri, 7 Sep 2018 11:44:37 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <EAF9E1C5-BEDD-4048-8A26-7E72D29A83BF@oracle.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <825DAB8C-9E0B-438D-9D36-7F1B188F86AD@oracle.com>
 <73fe659b96e30e1c1542352be32867a6fb7caa08.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 5, 2018, at 4:36 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Wed, 2018-09-05 at 15:33 -0400, Chuck Lever wrote:
>>> On Sep 5, 2018, at 3:23 PM, Trond Myklebust <trondmy@gmail.com>
>>> wrote:
>>>=20
>>> Fallout from a bunch of flame graphs...
>>=20
>> Hey, are these in a public git repo I can pull from?
>>=20
>=20
> I've pushed out my 'testing' branch to git.linux-nfs.org. The usual
> caveats apply: please do not treat that branch as being stable, assume
> it won't be rebased or assume that I won't change the contents. It is
> just there for testing purposes.
>=20
> Cheers
> Trond
>=20
>>=20
>>> Trond Myklebust (7):
>>> pNFS: Don't zero out the array in nfs4_alloc_pages()
>>> pNFS: Don't allocate more pages than we need to fit a layoutget
>>>   response
>>> NFS: Convert lookups of the lock context to RCU
>>> NFS: Simplify internal check for whether file is open for write
>>> NFS: Convert lookups of the open context to RCU
>>> NFSv4: Convert open state lookup to use RCU
>>> NFSv4: Convert struct nfs4_state to use refcount_t
>>>=20
>>> fs/nfs/delegation.c                    | 11 ++--
>>> fs/nfs/filelayout/filelayout.c         |  1 +
>>> fs/nfs/flexfilelayout/flexfilelayout.c |  1 +
>>> fs/nfs/inode.c                         | 70 +++++++++++----------
>>> -----
>>> fs/nfs/nfs4_fs.h                       |  3 +-
>>> fs/nfs/nfs4proc.c                      | 38 ++++++++++----
>>> fs/nfs/nfs4state.c                     | 32 ++++++------
>>> fs/nfs/pnfs.c                          | 16 ++++--
>>> fs/nfs/pnfs.h                          |  1 +
>>> include/linux/nfs_fs.h                 |  2 +
>>> 10 files changed, 98 insertions(+), 77 deletions(-)
>>>=20
>>> --=20
>>> 2.17.1

Some performance testing results for the full "testing" series.
The fio tests are designed to push the IOPS rate, and the third
is a QD=3D1 test to measure the latency of 512KB NFS WRITE
operations. All three tests use direct I/O.

The "without fair queuing" kernels have this commit reverted:

commit ae03d238e8a11ddc76668c64ad405cd8412446a6
Author:     Trond Myklebust <trond.myklebust@hammerspace.com>
AuthorDate: Tue Sep 4 11:47:51 2018 -0400
Commit:     Trond Myklebust <trond.myklebust@hammerspace.com>
CommitDate: Wed Sep 5 14:37:07 2018 -0400

    SUNRPC: Queue fairness for all.


Client: 12-core, two-socket, 56Gb InfiniBand
Server: 4-core, one-socket, 56Gb InfiniBand, tmpfs export

Test: /usr/bin/fio --size=3D1G --direct=3D1 --rw=3Drandrw =
--refill_buffers --norandommap --randrepeat=3D0 --ioengine=3Dlibaio =
--bs=3D8k --rwmixread=3D70 --iodepth=3D16 --numjobs=3D16 --runtime=3D240 =
--group_reporting

NFSv3 on RDMA:
Stock v4.19-rc2:
	=E2=80=A2 read: IOPS=3D109k, BW=3D849MiB/s =
(890MB/s)(11.2GiB/13506msec)
	=E2=80=A2 write: IOPS=3D46.6k, BW=3D364MiB/s =
(382MB/s)(4915MiB/13506msec)
Trond's kernel (with fair queuing):
	=E2=80=A2 read: IOPS=3D83.0k, BW=3D649MiB/s =
(680MB/s)(11.2GiB/17676msec)
	=E2=80=A2 write: IOPS=3D35.6k, BW=3D278MiB/s =
(292MB/s)(4921MiB/17676msec)
Trond's kernel (without fair queuing):
	=E2=80=A2 read: IOPS=3D90.5k, BW=3D707MiB/s =
(742MB/s)(11.2GiB/16216msec)
	=E2=80=A2 write: IOPS=3D38.8k, BW=3D303MiB/s =
(318MB/s)(4917MiB/16216msec)

NFSv3 on TCP (IPoIB):
Stock v4.19-rc2:
	=E2=80=A2 read: IOPS=3D23.8k, BW=3D186MiB/s =
(195MB/s)(11.2GiB/61635msec)
	=E2=80=A2 write: IOPS=3D10.2k, BW=3D79.9MiB/s =
(83.8MB/s)(4923MiB/61635msec)
Trond's kernel (with fair queuing):
	=E2=80=A2 read: IOPS=3D25.9k, BW=3D202MiB/s =
(212MB/s)(11.2GiB/56710msec)
	=E2=80=A2 write: IOPS=3D11.1k, BW=3D86.7MiB/s =
(90.9MB/s)(4916MiB/56710msec)
Trond's kernel (without fair queuing):
	=E2=80=A2 read: IOPS=3D25.0k, BW=3D203MiB/s =
(213MB/s)(11.2GiB/56492msec)
	=E2=80=A2 write: IOPS=3D11.1k, BW=3D86.0MiB/s =
(91.2MB/s)(4915MiB/56492msec)


Test: /usr/bin/fio --size=3D1G --direct=3D1 --rw=3Drandread =
--refill_buffers --norandommap --randrepeat=3D0 --ioengine=3Dlibaio =
--bs=3D4k --rwmixread=3D100 --iodepth=3D1024 --numjobs=3D16 =
--runtime=3D240 --group_reporting

NFSv3 on RDMA:
Stock v4.19-rc2:
	=E2=80=A2 read: IOPS=3D149k, BW=3D580MiB/s =
(608MB/s)(16.0GiB/28241msec)
Trond's kernel (with fair queuing):
	=E2=80=A2 read: IOPS=3D81.5k, BW=3D318MiB/s =
(334MB/s)(16.0GiB/51450msec)
Trond's kernel (without fair queuing):
	=E2=80=A2 read: IOPS=3D82.4k, BW=3D322MiB/s =
(337MB/s)(16.0GiB/50918msec)

NFSv3 on TCP (IPoIB):
Stock v4.19-rc2:
	=E2=80=A2 read: IOPS=3D37.2k, BW=3D145MiB/s =
(153MB/s)(16.0GiB/112630msec)
Trond's kernel (with fair queuing):
	=E2=80=A2 read: IOPS=3D2715, BW=3D10.6MiB/s =
(11.1MB/s)(2573MiB/242594msec)
Trond's kernel (without fair queuing):
	=E2=80=A2 read: IOPS=3D2869, BW=3D11.2MiB/s =
(11.8MB/s)(2724MiB/242979msec)


Test: /home/cel/bin/iozone -M -i0 -s8g -r512k -az -I -N

My kernel: 4.19.0-rc2-00026-g50d68a4
system call latencies in microseconds, N=3D5:
	=E2=80=A2 write:    mean=3D602, std=3D13.0
	=E2=80=A2 rewrite:  mean=3D541, std=3D17.3
server round trip latency in microseconds, N=3D5:
	=E2=80=A2 RTT:      mean=3D354, std=3D3.0

Trond's kernel (with fair queuing):
system call latencies in microseconds, N=3D5:
	=E2=80=A2 write:    mean=3D572, std=3D10.6
	=E2=80=A2 rewrite:  mean=3D533, std=3D7.9
server round trip latency in microseconds, N=3D5:
	=E2=80=A2 RTT:      mean=3D352, std=3D2.7


--
Chuck Lever
