Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:47624 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaC0HzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2014 03:55:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1WT59T-0004Ip-46
	for linux-nfs@vger.kernel.org; Thu, 27 Mar 2014 08:55:03 +0100
Received: from vpn.ims.co.at ([81.223.138.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 27 Mar 2014 08:55:03 +0100
Received: from rafael.reiter by vpn.ims.co.at with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 27 Mar 2014 08:55:03 +0100
To: linux-nfs@vger.kernel.org
From: Reiter Rafael <rafael.reiter@ims.co.at>
Subject: Re: Kernel oops/panic with NFS over RDMA mount after disrupted Infiniband
 connection
Date: Thu, 27 Mar 2014 08:53:50 +0100
Message-ID: <lh0le0$u5$1@ger.gmane.org>
References: <5332D425.3030803@ims.co.at> <4E6350BB-5E9C-40D9-8624-6CAA78E5B902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
In-Reply-To: <4E6350BB-5E9C-40D9-8624-6CAA78E5B902@oracle.com>
Cc: linux-rdma@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26/2014 07:15 PM, Chuck Lever wrote:
> 
> Hi Rafael-
> 
> I’ll take a look. Can you report your HCA and how you reproduce this issue?

The HCA is Mellanox Technologies MT26428.

Reproduction:
1) Mount a directory via NFS/RDMA
mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.2:/ /mnt/
2) Pull the Infiniband cable or use ibportstate to disrupt the Infiniband connection
3) ls /mnt
4) wait 5-30 seconds

> 
> Do you (or does anyone) know whether OpenSuSE uses the stock upstream providers, or has any of OFED been applied to this kernel?

My first post was misleading -- I use the vanilla 3.10.17 kernel, and the error occurs with and without Mellanox OFED. The above report
references the vanilla kernel.

Rafael

