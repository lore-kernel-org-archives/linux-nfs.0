Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33397 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbcDDTuu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2016 15:50:50 -0400
Received: by mail-yw0-f196.google.com with SMTP id o63so31312036ywe.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Apr 2016 12:50:50 -0700 (PDT)
Date: Mon, 4 Apr 2016 22:50:20 +0300
From: Leon Romanovsky <leon@leon.nu>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <Chuck.Lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH V2] nfs: add mount proto=rdma6 option for NFS/RDMA IPv6
 addressing
Message-ID: <20160404195020.GH5264@leon.nu>
Reply-To: leon@leon.nu
References: <56E9A650.7060409@oracle.com>
 <56F19F28.9020504@Netapp.com>
 <5702AF3F.90500@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5702AF3F.90500@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 04, 2016 at 11:15:27AM -0700, Shirley Ma wrote:
> RFC 5666: The "rdma" netid is to be used when IPv4 addressing
> is employed by the underlying transport, and "rdma6" for IPv6
> addressing.
> Add mount -o proto=rdma6 option to support NFS/RDMA IPv6 addressing.
> 
> Changes from v1:
>  - Integrated comments from Chuck Level, Anna Schumaker, Trodt Myklebust
>  - Add a little more to the patch description to describe NFS/RDMA
>    IPv6 usage
>  - Removed duplicated rdma6 define
>  - Removed Opt_xprt_rdma mountfamily since this doesn't support 
> 
> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>

It will be great if you can update the Documentation too.

Thanks
