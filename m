Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:49828 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758656Ab3BGPyf convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 10:54:35 -0500
From: Yan Burman <yanb@mellanox.com>
To: Jeff Becker <jeffrey.c.becker@nasa.gov>,
        Steve Wise <swise@opengridcomputing.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tom Tucker <tom@opengridcomputing.com>
Subject: RE: NFS over RDMA crashing
Date: Thu, 7 Feb 2013 15:54:13 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB873461151874C@MTLDAG01.mtl.com>
References: <51127B3F.2090200@mellanox.com>
 <51127DB1.6070804@opengridcomputing.com> <51128DAC.9000206@nasa.gov>
In-Reply-To: <51128DAC.9000206@nasa.gov>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jeff Becker [mailto:jeffrey.c.becker@nasa.gov]
> Sent: Wednesday, February 06, 2013 19:07
> To: Steve Wise
> Cc: Yan Burman; bfields@fieldses.org; linux-nfs@vger.kernel.org; linux-
> rdma@vger.kernel.org; Or Gerlitz; Tom Tucker
> Subject: Re: NFS over RDMA crashing
> 
> Hi. In case you're interested, I did the NFS/RDMA backports for OFED. I
> tested that NFS/RDMA in OFED 3.5 works on kernel 3.5, and also the RHEL
> 6.3 kernel. However, I did not test it with SRIOV. If you test it
> (OFED-3.5-rc6 was released last week), I'd like to know how it goes. Thanks.
> 
> Jeff Becker
> 
> On 02/06/2013 07:58 AM, Steve Wise wrote:
> > On 2/6/2013 9:48 AM, Yan Burman wrote:
> >> When I moved to commit 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e I
> was
> >> no longer getting the server crashes, so the reset of my tests were
> >> done using that point (it is somewhere in the middle of 3.7.0-rc2)
> >>
> > +tom tucker
> >
> > I'd try going back a few kernels, like to 3.5.x and see if things are
> > more stable.  If you find a point that works, then git bisect might
> > help identify the regression.
> > --

Vanilla 3.5.7 seem to work OK out of the box.
I will try 3.6 next week + performance comparisons.

Yan
