Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19136 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbdFWVfU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 17:35:20 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RESEND 0/3] Improvements to page writeback commit policy
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1498252656.8584.5.camel@primarydata.com>
Date: Fri, 23 Jun 2017 17:35:05 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BA2B31B0-932C-4FE5-8F11-BE92E09E3D3D@oracle.com>
References: <20170620233539.22417-1-trond.myklebust@primarydata.com> <C653223D-193D-4385-8AA1-11FD38C6CE89@oracle.com> <2062C819-C45A-4E8B-9222-78FB8270FB68@oracle.com> <1498252656.8584.5.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 23, 2017, at 5:17 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-06-23 at 16:48 -0400, Chuck Lever wrote:
>>> On Jun 21, 2017, at 10:31 AM, Chuck Lever <chuck.lever@oracle.com>
>>> wrote:
>>> 
>>>> 
>>>> On Jun 20, 2017, at 7:35 PM, Trond Myklebust <trond.myklebust@pri
>>>> marydata.com> wrote:
>>>> 
>>>> The following patches are intended to smooth out the page
>>>> writeback
>>>> performance by ensuring that we commit the data earlier on the
>>>> server.
>>>> 
>>>> We assume that if something is starting writeback on the pages,
>>>> then
>>>> that process wants to commit the data as soon as possible,
>>>> whether it
>>>> is an application or just the background flush process.
>>>> We also assume that for streaming type processes, we don't want
>>>> to pause
>>>> the I/O in order to commit, so we don't want to rely on a counter
>>>> of
>>>> in-flight I/O to the entire inode going to zero.
>>>> 
>>>> We therefore set up a monitor that counts the number of in-flight
>>>> writes for each call to nfs_writepages(). Once all the writes to
>>>> that
>>>> call to nfs_writepages has completed, we send the commit. Note
>>>> that this
>>>> mirrors the behaviour for O_DIRECT writes, where we similarly
>>>> track the
>>>> in-flight writes on a per-call basis.
>>> 
>>> These are the same as the patches you sent May 16th?
>>> I am trying to get a little time to try them out.
>> 
>> After applying these four patches, I ran a series of iozone
>> benchmarks with buffered and direct I/O. NFSv3 and NFSv4.0
>> on RDMA. Exports were tmpfs and xfs on NVMe.
>> 
>> I see about a 10% improvement in buffered write throughput,
>> no degradation elsewhere, and no crashes or other misbehav-
>> ior.
> 
> Cool! Thanks for testing.
> 
>> 
>> xfstests passes with the usual few failures.
>> 
>> Buffered write throughput is still limited to 1GBps when
>> targeting a tmpfs export on a 5.6GBps network. The server
>> isn't breaking a sweat, but the client appears to be hit-
>> ting some spin locks pretty hard. This is similar behavior
>> to before the patches were applied.
> 
> Just out of curiosity, do you see the same behaviour with O_DIRECT
> against the tmpfs?

No.


> There are 2 differences there:
> 1) no inode_lock(inode) contention.
> 2) slighly less inode->i_lock spinlock contention.

Here's buffered I/O, 1MB rsize/wsize:

	Include close in write timing
	Command line used: /home/cel/bin/iozone -i0 -i1 -s4g -y1k -az -c
	Output is in kBytes/sec
	Time Resolution = 0.000001 seconds.
	Processor cache size set to 1024 kBytes.
	Processor cache line size set to 32 bytes.
	File stride size set to 17 * record size.

              kB  reclen    write  rewrite    read    reread
         4194304       1   534253   570782  1445754  1354491
         4194304       2   734277   853665  2204343  2023764
         4194304       4   960679  1097920  3364254  2935551
         4194304       8   966103  1167984  4105734  3508967
         4194304      16  1035137  1218580  4251939  3626800
         4194304      32  1071914  1263524  4529706  3813485
         4194304      64  1078425  1221345  4631985  3865276
         4194304     128  1088618  1292963  4516240  3755776
         4194304     256  1076105  1236686  4148944  3535090
         4194304     512  1055872  1285594  4236854  3588770
         4194304    1024  1074738  1257684  4248442  3598040
         4194304    2048  1080189  1232026  4283919  3622818
         4194304    4096  1060772  1282839  4268281  3605311
         4194304    8192  1035067  1216913  3409080  2977354
         4194304   16384  1027003  1206250  2671951  2396517  

Here's direct I/O, 1MB rsize/wsize:

	O_DIRECT feature enabled
	Command line used: /home/cel/bin/iozone -i0 -i1 -s128m -y1k -az -I
	Output is in kBytes/sec
	Time Resolution = 0.000001 seconds.
	Processor cache size set to 1024 kBytes.
	Processor cache line size set to 32 bytes.
	File stride size set to 17 * record size.
                                    
              kB  reclen    write  rewrite    read    reread
          131072       1    23010    23523    25882    25831
          131072       2    45174    46255    51357    51406
          131072       4    69723    71039    93943    93880
          131072       8   131892   135438   179759   182036
          131072      16   245077   252067   335448   335486
          131072      32   415335   445705   600465   606896
          131072      64   647643   702595   923036   960093
          131072     128   910638   914057  1291528  1356444
          131072     256  1164078  1164266  1534979  1585828
          131072     512  1088692  1312085  1871873  1856387
          131072    1024  1243072  1363032  1858835  1925179
          131072    2048  1664066  1831074  2538926  2598939
          131072    4096  2205889  2392262  3608012  3686869
          131072    8192  2544002  2310414  4546863  4493238
          131072   16384  2597748  2164045  3629498  5016898


>>>> Trond Myklebust (3):
>>>> NFS: Remove unused fields in the page I/O structures
>>>> NFS: Ensure we commit after writeback is complete
>>>> NFS: Fix commit policy for non-blocking calls to
>>>> nfs_write_inode()
>>>> 
>>>> fs/nfs/pagelist.c聽聽聽聽聽聽聽聽|聽聽5 ++--
>>>> fs/nfs/write.c聽聽聽聽聽聽聽聽聽聽聽| 59
>>>> +++++++++++++++++++++++++++++++++++++++++++++++-
>>>> include/linux/nfs_page.h |聽聽2 +-
>>>> include/linux/nfs_xdr.h聽聽|聽聽3 ++-
>>>> 4 files changed, 64 insertions(+), 5 deletions(-)
>>>> 
>>>> --聽
>>>> 2.9.4
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-
>>>> nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at聽聽http://vger.kernel.org/majordomo-info.htm
>>>> l
>>> 
>>> --
>>> Chuck Lever
>>> 
>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at聽聽http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> ��N嫥叉靣笡y氊b瞂千v豝�)藓{.n�+壏{睗�"炟^n噐■��侂h櫒璀�&Ⅷ�瓽珴閔��(殠娸"濟���m��飦赇z罐枈帼f＂穐殘坢

--
Chuck Lever



