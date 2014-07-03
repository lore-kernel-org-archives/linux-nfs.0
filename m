Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-db3lp0084.outbound.protection.outlook.com ([213.199.154.84]:54487
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750978AbaGCMaj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 08:30:39 -0400
From: Yan Burman <yanb@mellanox.com>
To: Shirley Ma <shirley.ma@oracle.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Rupert Dance <rsdance@soft-forge.com>,
        "Chuck Lever" <chuck.lever@oracle.com>,
        Doug Ledford <dledford@redhat.com>,
        "Anna Schumaker" <Anna.Schumaker@netapp.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: RE: NFSoRDMA developers bi-weekly meeting minutes (6/25)
Date: Thu, 3 Jul 2014 12:14:38 +0000
Message-ID: <d3d3fd3f6f1c44159f0e6b9d19a622eb@DB4PR05MB461.eurprd05.prod.outlook.com>
References: <53B42F2A.9060205@oracle.com>
In-Reply-To: <53B42F2A.9060205@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Shirley,

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Shirley Ma
> Sent: Wednesday, July 02, 2014 19:11
> To: linux-rdma; Linux NFS Mailing List; Rupert Dance; Chuck Lever; Doug
> Ledford; Anna Schumaker; Steve Wise; Steve Dickson
> Subject: NFSoRDMA developers bi-weekly meeting minutes (6/25)
> 
> 
> 6. NFSoRDMA virtualization doesn't work. Shirley found that VF FRMR
> reported port error after a successful post_send on connextX-2. It didn't seem
> an NFSoRDMA issue. Questions are whether VF FRMR is fully tested. Later Yan
> confirmed VF FRMR doesn't work for NFSoRDMA on connectX-3 either.
> 

Apparently there has been a misunderstanding. I did not confirm that VF FRMR does not work.
Actually I use FRMR on VF all the time (not with NFSoRDMA apparently). You can check if FRMR works for you by running krping.

Regards,
Yan

