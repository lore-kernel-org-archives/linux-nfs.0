Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60266 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab0IOOEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 10:04:31 -0400
Date: Wed, 15 Sep 2010 10:04:29 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>,
        peter honeyman <honey@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: Deploying a pNFS / LAYOUT4_BLOCK_VOLUME configuration
Message-ID: <20100915140429.GA30887@merit.edu>
References: <4C8F6D39.2070406@cea.fr>
 <4C8F80DA.4030607@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C8F80DA.4030607@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  On 2010-09-14 14:40, DENIEL Philippe wrote:
  > Hi,
  > 
  > I'd like to set up from scratch a test bed using pNFS with block devices 
  > as I did a few month ago with LAYOUT4_NFSV4_1_FILES.
  > My question about the kernel and nfs-utils versions to be used ? Which 
  > one are the right ones ? Where could I get it ?
  
  Hi Philippe,
  
  The instructions are documented here:
  http://wiki.linux-nfs.org/wiki/index.php/PNFS_Block_Server_Setup_Instructions

I have added a section on the block layout client to the Fedora client setup
wiki page:

http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

For now the isntructions apply to Fedora, which is what we test with.
Eventually I will make this more generic.
