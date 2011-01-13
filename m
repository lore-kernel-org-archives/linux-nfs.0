Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:50530 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755683Ab1AMAHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 19:07:24 -0500
Date: Wed, 12 Jan 2011 19:07:20 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: state manager failed on NFSv4 server
Message-ID: <20110113000720.GA15353@merit.edu>
References: <20110112185843.GA14207@merit.edu>
 <1294859616.2971.46.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294859616.2971.46.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  The combination
  
          (EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS |
          EXCHGID4_FLAG_USE_NON_PNFS)
  
  is not listed in the table in section 13.1 of RFC5661 as an acceptable
  return value.

But section 13 doesn't apply to the block layout server, does it?
