Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-am1on0055.outbound.protection.outlook.com ([157.56.112.55]:36608
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752152AbaKXL7X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 06:59:23 -0500
From: Yan Burman <yanb@mellanox.com>
To: Shirley Ma <shirley.ma@oracle.com>, "Cheng, Wendy" <wendy.cheng@intel.com>,
        Charles EDWARD Lever <chuck.lever@oracle.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "Devesh.Sharma@emulex.com" <Devesh.Sharma@emulex.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "dominique.martinet@cea.fr" <dominique.martinet@cea.fr>,
        "jeffrey.c.becker@nasa.gov" <jeffrey.c.becker@nasa.gov>,
        "rsdance@soft-forge.com" <rsdance@soft-forge.com>,
        "skc@lanl.gov" <skc@lanl.gov>,
        "sprabhu@redhat.com" <sprabhu@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "swise@opengridcomputing.com" <swise@opengridcomputing.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: RE: NFSoRDMA developers bi-weekly meeting minutes (11/20)
Date: Mon, 24 Nov 2014 11:43:15 +0000
Message-ID: <fbe466929145478dade2c724f2134c40@DB4PR05MB461.eurprd05.prod.outlook.com>
References: <546E31C0.1070400@oracle.com>
 <1382BBBCFA085249836C0E3E91900D8999CA064C@ORSMSX115.amr.corp.intel.com>
 <546E645F.4090301@oracle.com>
In-Reply-To: <546E645F.4090301@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Shirley Ma [mailto:shirley.ma@oracle.com]
> Sent: Friday, November 21, 2014 00:00
> To: Cheng, Wendy; Charles EDWARD Lever; Anna.Schumaker@netapp.com;
> Devesh.Sharma@emulex.com; dledford@redhat.com;
> dominique.martinet@cea.fr; jeffrey.c.becker@nasa.gov; rsdance@soft-
> forge.com; skc@lanl.gov; sprabhu@redhat.com; SteveD@redhat.com;
> swise@opengridcomputing.com; Yan Burman; linux-rdma; Linux NFS Mailing
> List
> Subject: Re: NFSoRDMA developers bi-weekly meeting minutes (11/20)
> 
> 
> On 11/20/2014 12:15 PM, Cheng, Wendy wrote:
> >> -----Original Message-----
> >> From: Shirley Ma [mailto:shirley.ma@oracle.com]
> >> Sent: Thursday, November 20, 2014 10:24 AM
> >>
> >> ....
> >> iser 8K could reach 4.5GB/s in 56Gb/s link speed, 1.5 million IOPS.
> >> 32K could reach 1.8 million IOPS
> >>
> >
> > How did the ISER data get measured ? Was the measure done on ISER layer,
> block layer, or filesystem layer ?
> 
> Here is the link on iser how to set up and measure performance:
> http://community.mellanox.com/docs/DOC-1483

Actual numbers are (there seems to be some misunderstanding in the meeting minutes):
For single LUN/session in iSER on ConnectX-3 FDR link with 8 core 2.6GHz Xeon are:
8K block size reaches 2.5GB/s
Somewhere between 16K and 32K block size iSER reaches 5.5GB/s which is almost line rate
256K block size gives 5.7GB/s

With 16 sessions, it is possible to reach 1.7M IOPS with 1K block size and about 600K IOPS with 8K block size.

Note these numbers are for SCST iSER implementation and there are some more tunings and enhancements
that can be applied to further improve performance.

Another issue that came up is the benefit of RDMA vs send.
In order to check that you can use ib_send_lat vs ib_write_lat and see the latencies of different block sizes.
