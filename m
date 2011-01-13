Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:38439 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755542Ab1AMAa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 19:30:58 -0500
Date: Wed, 12 Jan 2011 19:30:55 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: state manager failed on NFSv4 server
Message-ID: <20110113003055.GC15353@merit.edu>
References: <20110112185843.GA14207@merit.edu>
 <1294859616.2971.46.camel@heimdal.trondhjem.org>
 <20110113000720.GA15353@merit.edu>
 <1294877939.15025.42.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294877939.15025.42.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  > But section 13 doesn't apply to the block layout server, does it?
  
  If you are a block layout server, the only valid return value is
  
  EXCHGID4_FLAG_USE_PNFS_MDS
    
  'cos you are clearly not a non-metadata server, and you clearly can't be
  a data server.

Sorry to be dense, this is the first time I've thought about this.

At the time of the EXCHANGE_ID call, how is the server supposed to know what
kind of layout is going to be negotiated?  It doesn't yet know whether the
client is even going to ask for a layout, does it?
