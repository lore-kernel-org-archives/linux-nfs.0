Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:38397 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab1AMAym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 19:54:42 -0500
Date: Wed, 12 Jan 2011 19:54:39 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: state manager failed on NFSv4 server
Message-ID: <20110113005439.GA15550@merit.edu>
References: <20110112185843.GA14207@merit.edu>
 <1294859616.2971.46.camel@heimdal.trondhjem.org>
 <20110113000720.GA15353@merit.edu>
 <1294877939.15025.42.camel@heimdal.trondhjem.org>
 <20110113003055.GC15353@merit.edu>
 <1294879039.15025.56.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294879039.15025.56.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  > At the time of the EXCHANGE_ID call, how is the server supposed to know what
  > kind of layout is going to be negotiated?  It doesn't yet know whether the
  > client is even going to ask for a layout, does it?
  
  It doesn't matter. EXCHGID4_FLAG_USE_PNFS_MDS is the server's way of
  advertising to the client that it supports LAYOUTGET and other pNFS
  related operations. The client is free to ignore that message if it so
  desires, and just use read/write through MDS. The point here is to tell
  the client whether or not it should try pNFS if it can.

I guess that makes sense.  But I think section 13 is a bit misleading since
it contains requirements for the block layout too.

13.  NFSv4.1 as a Storage Protocol in pNFS: the File Layout Type

   This section describes the semantics and format of NFSv4.1 file-based
   layouts for pNFS.  NFSv4.1 file-based layouts use the
   LAYOUT4_NFSV4_1_FILES layout type.  The LAYOUT4_NFSV4_1_FILES type
   defines striping data across multiple NFSv4.1 data servers.
