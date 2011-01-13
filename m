Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756434Ab1AMAhU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 19:37:20 -0500
Subject: Re: state manager failed on NFSv4 server
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110113003055.GC15353@merit.edu>
References: <20110112185843.GA14207@merit.edu>
	 <1294859616.2971.46.camel@heimdal.trondhjem.org>
	 <20110113000720.GA15353@merit.edu>
	 <1294877939.15025.42.camel@heimdal.trondhjem.org>
	 <20110113003055.GC15353@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 Jan 2011 19:37:19 -0500
Message-ID: <1294879039.15025.56.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-12 at 19:30 -0500, Jim Rees wrote: 
> Trond Myklebust wrote:
> 
>   > But section 13 doesn't apply to the block layout server, does it?
>   
>   If you are a block layout server, the only valid return value is
>   
>   EXCHGID4_FLAG_USE_PNFS_MDS
>     
>   'cos you are clearly not a non-metadata server, and you clearly can't be
>   a data server.
> 
> Sorry to be dense, this is the first time I've thought about this.
> 
> At the time of the EXCHANGE_ID call, how is the server supposed to know what
> kind of layout is going to be negotiated?  It doesn't yet know whether the
> client is even going to ask for a layout, does it?

It doesn't matter. EXCHGID4_FLAG_USE_PNFS_MDS is the server's way of
advertising to the client that it supports LAYOUTGET and other pNFS
related operations. The client is free to ignore that message if it so
desires, and just use read/write through MDS. The point here is to tell
the client whether or not it should try pNFS if it can.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

