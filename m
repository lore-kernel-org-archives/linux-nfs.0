Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:33050 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755234Ab3D2MQp convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Apr 2013 08:16:45 -0400
From: Yan Burman <yanb@mellanox.com>
To: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: RE: NFS over RDMA benchmark
Date: Mon, 29 Apr 2013 12:16:09 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB873462CF9B3E7@MTLDAG01.mtl.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
	<CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
	<62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
	<CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
	<20130423210607.GJ3676@fieldses.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
	<20130424150540.GB20275@fieldses.org>	<20130424152631.GC20275@fieldses.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com>
	<20130428144248.GA2037@fieldses.org>
 <CABgxfbF9MepShtOP8EoTjfMXzU4LLWC7brTmMfa3rtoWBiOweg@mail.gmail.com>
In-Reply-To: <CABgxfbF9MepShtOP8EoTjfMXzU4LLWC7brTmMfa3rtoWBiOweg@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Wendy Cheng [mailto:s.wendy.cheng@gmail.com]
> Sent: Monday, April 29, 2013 08:35
> To: J. Bruce Fields
> Cc: Yan Burman; Atchley, Scott; Tom Tucker; linux-rdma@vger.kernel.org;
> linux-nfs@vger.kernel.org; Or Gerlitz
> Subject: Re: NFS over RDMA benchmark
> 
> On Sun, Apr 28, 2013 at 7:42 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman
> 
> >> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
> >> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the
> > > same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.
> > ...
> 
> [snip]
> 
> >>     36.18%          nfsd  [kernel.kallsyms]   [k] mutex_spin_on_owner
> >
> > That's the inode i_mutex.
> >
> >>     14.70%-- svc_send
> >
> > That's the xpt_mutex (ensuring rpc replies aren't interleaved).
> >
> >>
> >>      9.63%          nfsd  [kernel.kallsyms]   [k] _raw_spin_lock_irqsave
> >>
> >
> > And that (and __free_iova below) looks like iova_rbtree_lock.
> >
> >
> 
> Let's revisit your command:
> 
> "FIO arguments: --rw=randread --bs=4k --numjobs=2 --iodepth=128 --
> ioengine=libaio --size=100000k --prioclass=1 --prio=0 --cpumask=255
> --loops=25 --direct=1 --invalidate=1 --fsync_on_close=1 --randrepeat=1 --
> norandommap --group_reporting --exitall --buffered=0"
> 

I tried block sizes from 4-512K.
4K does not give 2.2GB bandwidth - optimal bandwidth is achieved around 128-256K block size

> * inode's i_mutex:
> If increasing process/file count didn't help, maybe increase "iodepth"
> (say 512 ?) could offset the i_mutex overhead a little bit ?
> 

I tried with different iodepth parameters, but found no improvement above iodepth 128.

> * xpt_mutex:
> (no idea)
> 
> * iova_rbtree_lock
> DMA mapping fragmentation ? I have not studied whether NFS-RDMA
> routines such as "svc_rdma_sendto()" could do better but maybe sequential
> IO (instead of "randread") could help ? Bigger block size (instead of 4K) can
> help ?
> 

I am trying to simulate real load (more or less), that is the reason I use randread. Anyhow, read does not result in better performance.
It's probably because backing storage is tmpfs...

Yan

