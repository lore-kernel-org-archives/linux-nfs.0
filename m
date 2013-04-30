Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:44040 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751254Ab3D3FJh convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 01:09:37 -0400
From: Yan Burman <yanb@mellanox.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: RE: NFS over RDMA benchmark
Date: Tue, 30 Apr 2013 05:09:27 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB873462CF9C90C@MTLDAG01.mtl.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
 <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
 <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
 <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
 <20130423210607.GJ3676@fieldses.org>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
 <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com>
 <20130428144248.GA2037@fieldses.org>
In-Reply-To: <20130428144248.GA2037@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Sunday, April 28, 2013 17:43
> To: Yan Burman
> Cc: Wendy Cheng; Atchley, Scott; Tom Tucker; linux-rdma@vger.kernel.org;
> linux-nfs@vger.kernel.org; Or Gerlitz
> Subject: Re: NFS over RDMA benchmark
> 
> On Sun, Apr 28, 2013 at 06:28:16AM +0000, Yan Burman wrote:
> > > > > > > > >> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman
> > > > > > > > >> <yanb@mellanox.com>
> > > > > > > > >>> I've been trying to do some benchmarks for NFS over
> > > > > > > > >>> RDMA and I seem to
> > > > > > > > only get about half of the bandwidth that the HW can give me.
> > > > > > > > >>> My setup consists of 2 servers each with 16 cores,
> > > > > > > > >>> 32Gb of memory, and
> > > > > > > > Mellanox ConnectX3 QDR card over PCI-e gen3.
> > > > > > > > >>> These servers are connected to a QDR IB switch. The
> > > > > > > > >>> backing storage on
> > > > > > > > the server is tmpfs mounted with noatime.
> > > > > > > > >>> I am running kernel 3.5.7.
> > > > > > > > >>>
> > > > > > > > >>> When running ib_send_bw, I get 4.3-4.5 GB/sec for
> > > > > > > > >>> block sizes 4-
> > > 512K.
> > > > > > > > >>> When I run fio over rdma mounted nfs, I get
> > > > > > > > >>> 260-2200MB/sec for the
> > > > > > > > same block sizes (4-512K). running over IPoIB-CM, I get
> > > > > > > > 200-
> > > 980MB/sec.
> ...
> > > > > > > I am trying to get maximum performance from a single server
> > > > > > > - I used 2
> > > > > > processes in fio test - more than 2 did not show any performance
> boost.
> > > > > > > I tried running fio from 2 different PCs on 2 different
> > > > > > > files, but the sum of
> > > > > > the two is more or less the same as running from single client PC.
> > > > > > >

I finally got up to 4.1GB/sec bandwidth with RDMA (ipoib-CM bandwidth is also way higher now).
For some reason when I had intel IOMMU enabled, the performance dropped significantly.
I now get up to ~95K IOPS and 4.1GB/sec bandwidth.
Now I will take care of the issue that I am running only at 40Gbit/s instead of 56Gbit/s, but that is another unrelated problem (I suspect I have a cable issue).

This is still strange, since ib_send_bw with intel iommu enabled did get up to 4.5GB/sec, so why did intel iommu affect only nfs code?

Yan

