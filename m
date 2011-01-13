Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49540 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756294Ab1AMATC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 19:19:02 -0500
Subject: Re: state manager failed on NFSv4 server
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110113000720.GA15353@merit.edu>
References: <20110112185843.GA14207@merit.edu>
	 <1294859616.2971.46.camel@heimdal.trondhjem.org>
	 <20110113000720.GA15353@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 Jan 2011 19:18:59 -0500
Message-ID: <1294877939.15025.42.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-12 at 19:07 -0500, Jim Rees wrote: 
> Trond Myklebust wrote:
> 
>   The combination
>   
>           (EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS |
>           EXCHGID4_FLAG_USE_NON_PNFS)
>   
>   is not listed in the table in section 13.1 of RFC5661 as an acceptable
>   return value.
> 
> But section 13 doesn't apply to the block layout server, does it?

If you are a block layout server, the only valid return value is

EXCHGID4_FLAG_USE_PNFS_MDS
  
'cos you are clearly not a non-metadata server, and you clearly can't be
a data server.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

