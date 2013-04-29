Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:41505 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab3D2Fev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Apr 2013 01:34:51 -0400
MIME-Version: 1.0
In-Reply-To: <20130428144248.GA2037@fieldses.org>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
	<CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
	<62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
	<CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
	<20130423210607.GJ3676@fieldses.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
	<20130424150540.GB20275@fieldses.org>
	<20130424152631.GC20275@fieldses.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com>
	<20130428144248.GA2037@fieldses.org>
Date: Sun, 28 Apr 2013 22:34:50 -0700
Message-ID: <CABgxfbF9MepShtOP8EoTjfMXzU4LLWC7brTmMfa3rtoWBiOweg@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Yan Burman <yanb@mellanox.com>, "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 28, 2013 at 7:42 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

>> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman

>> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
>> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the
> > same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.
> ...

[snip]

>>     36.18%          nfsd  [kernel.kallsyms]   [k] mutex_spin_on_owner
>
> That's the inode i_mutex.
>
>>     14.70%-- svc_send
>
> That's the xpt_mutex (ensuring rpc replies aren't interleaved).
>
>>
>>      9.63%          nfsd  [kernel.kallsyms]   [k] _raw_spin_lock_irqsave
>>
>
> And that (and __free_iova below) looks like iova_rbtree_lock.
>
>

Let's revisit your command:

"FIO arguments: --rw=randread --bs=4k --numjobs=2 --iodepth=128
--ioengine=libaio --size=100000k --prioclass=1 --prio=0 --cpumask=255
--loops=25 --direct=1 --invalidate=1 --fsync_on_close=1 --randrepeat=1
--norandommap --group_reporting --exitall --buffered=0"

* inode's i_mutex:
If increasing process/file count didn't help, maybe increase "iodepth"
(say 512 ?) could offset the i_mutex overhead a little bit ?

* xpt_mutex:
(no idea)

* iova_rbtree_lock
DMA mapping fragmentation ? I have not studied whether NFS-RDMA
routines such as "svc_rdma_sendto()" could do better but maybe
sequential IO (instead of "randread") could help ? Bigger block size
(instead of 4K) can help ?

-- Wendy
