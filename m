Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p3plsmtpa06-06.prod.phx3.secureserver.net ([173.201.192.107]:60212
	"EHLO p3plsmtpa06-06.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759128Ab3D3OUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Apr 2013 10:20:25 -0400
Message-ID: <517FD327.3060901@talpey.com>
Date: Tue, 30 Apr 2013 10:20:23 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Yan Burman <yanb@mellanox.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Wendy Cheng <s.wendy.cheng@gmail.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com> <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com> <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov> <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com> <20130423210607.GJ3676@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com> <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com> <20130428144248.GA2037@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF9C90C@MTLDAG01.mtl.com>
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF9C90C@MTLDAG01.mtl.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/30/2013 1:09 AM, Yan Burman wrote:
> I now get up to ~95K IOPS and 4.1GB/sec bandwidth.
>...
>  ib_send_bw with intel iommu enabled did get up to 4.5GB/sec

BTW, you may want to verify that these are the same GB. Many
benchmarks say KB/MB/GB when they really mean KiB/MiB/GiB.

At GB/GiB, the difference is about 7.5%, very close to the
difference between 4.1 and 4.5.

Just a thought.
