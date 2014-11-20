Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:64574 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757979AbaKTUP4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 15:15:56 -0500
From: "Cheng, Wendy" <wendy.cheng@intel.com>
To: Shirley Ma <shirley.ma@oracle.com>,
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
        "yanb@mellanox.com" <yanb@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: RE: NFSoRDMA developers bi-weekly meeting minutes (11/20)
Date: Thu, 20 Nov 2014 20:15:52 +0000
Message-ID: <1382BBBCFA085249836C0E3E91900D8999CA064C@ORSMSX115.amr.corp.intel.com>
References: <546E31C0.1070400@oracle.com>
In-Reply-To: <546E31C0.1070400@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Shirley Ma [mailto:shirley.ma@oracle.com]
> Sent: Thursday, November 20, 2014 10:24 AM
> 
> ....
> iser 8K could reach 4.5GB/s in 56Gb/s link speed, 1.5 million IOPS. 32K could
> reach 1.8 million IOPS
> 

How did the ISER data get measured ? Was the measure done on ISER layer, block layer, or filesystem layer ?

-- Wendy 
 

