Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45632 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756620AbcDDUXf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2016 16:23:35 -0400
Message-ID: <5702CD3B.4030207@oracle.com>
Date: Mon, 04 Apr 2016 13:23:23 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: leon@leon.nu
CC: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <Chuck.Lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH V2] nfs: add mount proto=rdma6 option for NFS/RDMA IPv6
 addressing
References: <56E9A650.7060409@oracle.com> <56F19F28.9020504@Netapp.com> <5702AF3F.90500@oracle.com> <20160404195020.GH5264@leon.nu>
In-Reply-To: <20160404195020.GH5264@leon.nu>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 04/04/2016 12:50 PM, Leon Romanovsky wrote:
> On Mon, Apr 04, 2016 at 11:15:27AM -0700, Shirley Ma wrote:
>> RFC 5666: The "rdma" netid is to be used when IPv4 addressing
>> is employed by the underlying transport, and "rdma6" for IPv6
>> addressing.
>> Add mount -o proto=rdma6 option to support NFS/RDMA IPv6 addressing.
>>
>> Changes from v1:
>>  - Integrated comments from Chuck Level, Anna Schumaker, Trodt Myklebust
>>  - Add a little more to the patch description to describe NFS/RDMA
>>    IPv6 usage
>>  - Removed duplicated rdma6 define
>>  - Removed Opt_xprt_rdma mountfamily since this doesn't support 
>>
>> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
> 
> It will be great if you can update the Documentation too.

Sure, I will update documentation and man page.
 
> Thanks
> 
