Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:36134 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754422AbaC0P7R convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2014 11:59:17 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Kernel oops/panic with NFS over RDMA mount after disrupted Infiniband connection
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <lh0le0$u5$1@ger.gmane.org>
Date: Thu, 27 Mar 2014 08:59:06 -0700
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B7D4A29C-5E1F-4B6C-A8FC-C46D8DF6A87D@oracle.com>
References: <5332D425.3030803@ims.co.at> <4E6350BB-5E9C-40D9-8624-6CAA78E5B902@oracle.com> <lh0le0$u5$1@ger.gmane.org>
To: Reiter Rafael <rafael.reiter@ims.co.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-


On Mar 27, 2014, at 12:53 AM, Reiter Rafael <rafael.reiter@ims.co.at> wrote:

> On 03/26/2014 07:15 PM, Chuck Lever wrote:
>> 
>> Hi Rafael-
>> 
>> I’ll take a look. Can you report your HCA and how you reproduce this issue?
> 
> The HCA is Mellanox Technologies MT26428.
> 
> Reproduction:
> 1) Mount a directory via NFS/RDMA
> mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.2:/ /mnt/
> 2) Pull the Infiniband cable or use ibportstate to disrupt the Infiniband connection
> 3) ls /mnt
> 4) wait 5-30 seconds

Thanks for the information.

I have that HCA, but I won’t have access to my test systems for a week (traveling). So can you try this:

 # rpcdebug -m rpc -s trans

then reproduce (starting with step 1 above). Some debugging output will appear at the tail of /var/log/messages. Copy it to this thread.

> 
>> 
>> Do you (or does anyone) know whether OpenSuSE uses the stock upstream providers, or has any of OFED been applied to this kernel?
> 
> My first post was misleading -- I use the vanilla 3.10.17 kernel, and the error occurs with and without Mellanox OFED. The above report
> references the vanilla kernel.
> 
> Rafael
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



