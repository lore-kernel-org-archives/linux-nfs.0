Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:30542 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbaGQOM4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 10:12:56 -0400
From: Devesh Sharma <Devesh.Sharma@Emulex.Com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH v3 00/21] NFS/RDMA client patches for 3.17
Date: Thu, 17 Jul 2014 14:12:31 +0000
Message-ID: <3cf9f937-4c1c-4a39-9fb8-aca5eea15880@CMEXHTCAS2.ad.emulex.com>
References: <59034BAD-306F-462F-A274-3EB06C0CBE47@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FE10DE1@CMEXMB1.ad.emulex.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FE10DE1@CMEXMB1.ad.emulex.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Tested the cable pull also. V3 is passing the cable pull test also. I have tried following tests:

Run iozone on nfs-rdma mount.
Bring down the link from switch (to simulate cable pull).
Wait for 10 secs.
Bring back the link.
This test passes, iozone resumes traffic.

Run iozone on nfs-rdma mount.
Bring down the link from switch (to simulate cable pull).
Wait for 70 secs.
Bring back the link.
This test passes, iozone resumes traffic.

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Devesh Sharma
> Sent: Thursday, July 17, 2014 10:37 AM
> To: Chuck Lever; linux-rdma; Linux NFS Mailing List
> Subject: RE: [PATCH v3 00/21] NFS/RDMA client patches for 3.17
> 
> Hi Chuck,
> 
> 
> Tested v3 with  ocrdma (linux-3.16-rc5 inbox`ed ocrdma). Both Cthon and
> iozone passes with and regressions. I will perform cable pull test as well and
> get back to you.
> 
> -Regards
>  Devesh
> 
> > -----Original Message-----
> > From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> > owner@vger.kernel.org] On Behalf Of Chuck Lever
> > Sent: Tuesday, July 15, 2014 7:54 PM
> > To: linux-rdma; Linux NFS Mailing List
> > Subject: [PATCH v3 00/21] NFS/RDMA client patches for 3.17
> >
> > The main purpose of this series is to address connection drop recovery
> > issues by fixing FRMR re-use to make it less likely the client will
> > deadlock due to a memory management operation error.
> >
> > Some clean-ups and other fixes are present as well.
> >
> > See topic branch nfs-rdma-for-3.17 in
> >
> > git://git.linux-nfs.org/projects/cel/cel-2.6.git
> >
> > I tested with NFSv3 and NFSv4 on all three supported memory
> > registration modes. Used cthon04, iozone, and dbench with both Solaris
> > and Linux NFS/RDMA servers. Used xfstests with Linux.
> >
> > v3:
> > Only two substantive changes:
> >
> > - Patch 08/21 now uses generic IB helpers for managing FRMR
> >   rkeys
> >
> > - Add Tested-by: from Steve Wise
> >
> >
> > v2:
> > Many patches from v1 have been written or replaced.
> >
> > The MW ref counting approach in v1 is abandoned. Instead, I've
> > eliminated signaling FAST_REG_MR and LOCAL_INV, and added
> appropriate
> > recovery mechanisms after a transport reconnect that should prevent
> > rkey dis- synchrony entirely.
> >
> > A couple of optimizations have been added, including:
> >
> > - Allocating each MW separately rather than carving each out of a
> >   large piece of contiguous memory
> >
> > - Now that the receive CQ upcall handler dequeues a bundle of CQEs
> >   at once, fire off the reply handler tasklet just once per upcall
> >   to reduce context switches and how often hard IRQs are disabled
> >
> > Jury is still out on the latter.
> >
> > --
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> >
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-rdma"
> > in the body of a message to majordomo@vger.kernel.org More
> majordomo
> > info at http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
