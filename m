Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22629 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757022AbaKTWAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 17:00:25 -0500
Message-ID: <546E645F.4090301@oracle.com>
Date: Thu, 20 Nov 2014 13:59:59 -0800
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "Cheng, Wendy" <wendy.cheng@intel.com>,
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
Subject: Re: NFSoRDMA developers bi-weekly meeting minutes (11/20)
References: <546E31C0.1070400@oracle.com> <1382BBBCFA085249836C0E3E91900D8999CA064C@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <1382BBBCFA085249836C0E3E91900D8999CA064C@ORSMSX115.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 11/20/2014 12:15 PM, Cheng, Wendy wrote:
>> -----Original Message-----
>> From: Shirley Ma [mailto:shirley.ma@oracle.com]
>> Sent: Thursday, November 20, 2014 10:24 AM
>>
>> ....
>> iser 8K could reach 4.5GB/s in 56Gb/s link speed, 1.5 million IOPS. 32K could
>> reach 1.8 million IOPS
>>
> 
> How did the ISER data get measured ? Was the measure done on ISER layer, block layer, or filesystem layer ?

Here is the link on iser how to set up and measure performance:
http://community.mellanox.com/docs/DOC-1483
