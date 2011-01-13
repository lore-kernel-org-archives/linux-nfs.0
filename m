Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48143 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab1AMNXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 08:23:50 -0500
Message-ID: <4D2EFCDF.8060507@panasas.com>
Date: Thu, 13 Jan 2011 15:23:43 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: state manager failed on NFSv4 server
References: <20110112185843.GA14207@merit.edu> <1294859616.2971.46.camel@heimdal.trondhjem.org> <20110113000720.GA15353@merit.edu> <1294877939.15025.42.camel@heimdal.trondhjem.org> <20110113003055.GC15353@merit.edu> <1294879039.15025.56.camel@heimdal.trondhjem.org> <20110113005439.GA15550@merit.edu>
In-Reply-To: <20110113005439.GA15550@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-01-13 02:54, Jim Rees wrote:
> Trond Myklebust wrote:
> 
>   > At the time of the EXCHANGE_ID call, how is the server supposed to know what
>   > kind of layout is going to be negotiated?  It doesn't yet know whether the
>   > client is even going to ask for a layout, does it?
>   
>   It doesn't matter. EXCHGID4_FLAG_USE_PNFS_MDS is the server's way of
>   advertising to the client that it supports LAYOUTGET and other pNFS
>   related operations. The client is free to ignore that message if it so
>   desires, and just use read/write through MDS. The point here is to tell
>   the client whether or not it should try pNFS if it can.
> 
> I guess that makes sense.  But I think section 13 is a bit misleading since
> it contains requirements for the block layout too.

True, but section 18.35. Operation 42: EXCHANGE_ID - Instantiate Client ID
specifically says:

   The EXCHGID4_FLAG_USE_NON_PNFS, EXCHGID4_FLAG_USE_PNFS_MDS, and
   EXCHGID4_FLAG_USE_PNFS_DS bits are described in Section 13.1 and
   convey roles the client ID is to be used for in a pNFS environment.
   The server MUST set one of the acceptable combinations of these bits
   (roles) in eir_flags, as specified in Section 13.1.

Benny

> 
> 13.  NFSv4.1 as a Storage Protocol in pNFS: the File Layout Type
> 
>    This section describes the semantics and format of NFSv4.1 file-based
>    layouts for pNFS.  NFSv4.1 file-based layouts use the
>    LAYOUT4_NFSV4_1_FILES layout type.  The LAYOUT4_NFSV4_1_FILES type
>    defines striping data across multiple NFSv4.1 data servers.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
