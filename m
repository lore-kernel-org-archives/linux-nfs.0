Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:44652 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728126AbeIJVJ2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 17:09:28 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 0/7] Misc NFS + pNFS performance enhancements
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <36234cfa0a906b0924b6bee34e245126001010c9.camel@hammerspace.com>
Date: Mon, 10 Sep 2018 12:14:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D1ED2ED9-E882-4F8B-9C1A-2D42EF06A281@oracle.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <825DAB8C-9E0B-438D-9D36-7F1B188F86AD@oracle.com>
 <73fe659b96e30e1c1542352be32867a6fb7caa08.camel@hammerspace.com>
 <EAF9E1C5-BEDD-4048-8A26-7E72D29A83BF@oracle.com>
 <36234cfa0a906b0924b6bee34e245126001010c9.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 9, 2018, at 9:35 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Fri, 2018-09-07 at 11:44 -0400, Chuck Lever wrote:
>>=20
>> Client: 12-core, two-socket, 56Gb InfiniBand
>> Server: 4-core, one-socket, 56Gb InfiniBand, tmpfs export
>>=20
>> Test: /usr/bin/fio --size=3D1G --direct=3D1 --rw=3Drandrw =
--refill_buffers
>> --norandommap --randrepeat=3D0 --ioengine=3Dlibaio --bs=3D8k =
--rwmixread=3D70=20
>> --iodepth=3D16 --numjobs=3D16 --runtime=3D240 --group_reporting
>>=20
>> NFSv3 on RDMA:
>> Stock v4.19-rc2:
>> 	=E2=80=A2 read: IOPS=3D109k, BW=3D849MiB/s =
(890MB/s)(11.2GiB/13506msec)
>> 	=E2=80=A2 write: IOPS=3D46.6k, BW=3D364MiB/s =
(382MB/s)(4915MiB/13506msec)
>> Trond's kernel (with fair queuing):
>> 	=E2=80=A2 read: IOPS=3D83.0k, BW=3D649MiB/s =
(680MB/s)(11.2GiB/17676msec)
>> 	=E2=80=A2 write: IOPS=3D35.6k, BW=3D278MiB/s =
(292MB/s)(4921MiB/17676msec)
>> Trond's kernel (without fair queuing):
>> 	=E2=80=A2 read: IOPS=3D90.5k, BW=3D707MiB/s =
(742MB/s)(11.2GiB/16216msec)
>> 	=E2=80=A2 write: IOPS=3D38.8k, BW=3D303MiB/s =
(318MB/s)(4917MiB/16216msec)
>>=20
>> NFSv3 on TCP (IPoIB):
>> Stock v4.19-rc2:
>> 	=E2=80=A2 read: IOPS=3D23.8k, BW=3D186MiB/s =
(195MB/s)(11.2GiB/61635msec)
>> 	=E2=80=A2 write: IOPS=3D10.2k, BW=3D79.9MiB/s =
(83.8MB/s)(4923MiB/61635msec)
>> Trond's kernel (with fair queuing):
>> 	=E2=80=A2 read: IOPS=3D25.9k, BW=3D202MiB/s =
(212MB/s)(11.2GiB/56710msec)
>> 	=E2=80=A2 write: IOPS=3D11.1k, BW=3D86.7MiB/s =
(90.9MB/s)(4916MiB/56710msec)
>> Trond's kernel (without fair queuing):
>> 	=E2=80=A2 read: IOPS=3D25.0k, BW=3D203MiB/s =
(213MB/s)(11.2GiB/56492msec)
>> 	=E2=80=A2 write: IOPS=3D11.1k, BW=3D86.0MiB/s =
(91.2MB/s)(4915MiB/56492msec)
>>=20
>>=20
>> Test: /usr/bin/fio --size=3D1G --direct=3D1 --rw=3Drandread --
>> refill_buffers --norandommap --randrepeat=3D0 --ioengine=3Dlibaio =
--bs=3D4k=20
>> --rwmixread=3D100 --iodepth=3D1024 --numjobs=3D16 --runtime=3D240 --
>> group_reporting
>>=20
>> NFSv3 on RDMA:
>> Stock v4.19-rc2:
>> 	=E2=80=A2 read: IOPS=3D149k, BW=3D580MiB/s =
(608MB/s)(16.0GiB/28241msec)
>> Trond's kernel (with fair queuing):
>> 	=E2=80=A2 read: IOPS=3D81.5k, BW=3D318MiB/s =
(334MB/s)(16.0GiB/51450msec)
>> Trond's kernel (without fair queuing):
>> 	=E2=80=A2 read: IOPS=3D82.4k, BW=3D322MiB/s =
(337MB/s)(16.0GiB/50918msec)
>>=20
>> NFSv3 on TCP (IPoIB):
>> Stock v4.19-rc2:
>> 	=E2=80=A2 read: IOPS=3D37.2k, BW=3D145MiB/s =
(153MB/s)(16.0GiB/112630msec)
>> Trond's kernel (with fair queuing):
>> 	=E2=80=A2 read: IOPS=3D2715, BW=3D10.6MiB/s =
(11.1MB/s)(2573MiB/242594msec)
>> Trond's kernel (without fair queuing):
>> 	=E2=80=A2 read: IOPS=3D2869, BW=3D11.2MiB/s =
(11.8MB/s)(2724MiB/242979msec)
>>=20
>>=20
>> Test: /home/cel/bin/iozone -M -i0 -s8g -r512k -az -I -N
>>=20
>> My kernel: 4.19.0-rc2-00026-g50d68a4
>> system call latencies in microseconds, N=3D5:
>> 	=E2=80=A2 write:    mean=3D602, std=3D13.0
>> 	=E2=80=A2 rewrite:  mean=3D541, std=3D17.3
>> server round trip latency in microseconds, N=3D5:
>> 	=E2=80=A2 RTT:      mean=3D354, std=3D3.0
>>=20
>> Trond's kernel (with fair queuing):
>> system call latencies in microseconds, N=3D5:
>> 	=E2=80=A2 write:    mean=3D572, std=3D10.6
>> 	=E2=80=A2 rewrite:  mean=3D533, std=3D7.9
>> server round trip latency in microseconds, N=3D5:
>> 	=E2=80=A2 RTT:      mean=3D352, std=3D2.7
>=20
> Thanks for testing! I've been spending the last 3 days trying to =
figure
> out why we're seeing regressions with RDMA. I think I have a few
> candidates:
>=20
> - The congestion control was failing to wake up the write lock when we
> queue a request that has already been allocated a congestion control
> credit.
> - The livelock avoidance code in xprt_transmit() was causing the
> queueing to break.
> - Incorrect return value returned by xprt_transmit() when the queue is
> empty causes the request to retry waiting for the lock.
> - A race in xprt_prepare_transmit() could cause the request to wait =
for
> the write lock despite having been transmitted by another request.
> - The change to convert the write lock into a non-priority queue also
> changed the wake up code, causing the request that is granted the lock
> to be queued on rpciod, instead of on the low-latency xprtiod
> workqueue.
>=20
> I've fixed all the above. In addition, I've tightened up a few cases
> where we were grabbing spinlocks unnecessarily, and I've converted the
> reply lookup to use an rbtree in order to reduce the amount of time we
> need to hold the xprt->queue_lock.
>=20
> The new code has been rebased onto 4.19.0-rc3, and is now available on
> the 'testing' branch. Would you be able to give it another quick spin?

We're in much better shape now. Compare the stock v4.19-rc2
numbers above with these from your latest testing branch.
The new results show a consistent 10% throughput improvement.

test 1 from above:

NFSv3 on RDMA:
4.19.0-rc3-13903-g11dddfd:
	=E2=80=A2 read: IOPS=3D118k, BW=3D921MiB/s =
(966MB/s)(11.2GiB/12469msec)
	=E2=80=A2 write: IOPS=3D50.3k, BW=3D393MiB/s =
(412MB/s)(4899MiB/12469msec)

NFSv3 on TCP (IPoIB):
4.19.0-rc3-13903-g11dddfd:
	=E2=80=A2 read: IOPS=3D27.4k, BW=3D214MiB/s =
(224MB/s)(11.2GiB/53650msec)
	=E2=80=A2 write: IOPS=3D11.7k, BW=3D91.6MiB/s =
(96.0MB/s)(4913MiB/53650msec)


test 2 from above:

NFSv3 on RDMA:
4.19.0-rc3-13903-g11dddfd:
	=E2=80=A2 read: IOPS=3D163k, BW=3D636MiB/s =
(667MB/s)(16.0GiB/25743msec)

NFSv3 on TCP (IPoIB):
4.19.0-rc3-13903-g11dddfd:
	=E2=80=A2 read: IOPS=3D44.2k, BW=3D173MiB/s =
(181MB/s)(16.0GiB/94898msec)


--
Chuck Lever
