Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4231 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755007Ab0IKANN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 20:13:13 -0400
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20100911000749.GA31628@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
	 <1284147111.10062.74.camel@heimdal.trondhjem.org>
	 <20100910235600.GA11231@infradead.org>
	 <1284163433.14078.102.camel@heimdal.trondhjem.org>
	 <20100911000749.GA31628@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 20:13:00 -0400
Message-ID: <1284163980.14078.111.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 20:07 -0400, Christoph Hellwig wrote:
> On Fri, Sep 10, 2010 at 08:03:53PM -0400, Trond Myklebust wrote:
> > So you are saying we should simply equate CONFIG_PNFS_FILE_LAYOUT and
> > CONFIG_NFS_V4_1 right now? Yep, I'd be fine with that... I'm still
> > working on the patches to get rid of all these CONFIG options, but
> > ultimately this is what I'm working towards.
> 
> If you don't want a separate option that's up to you, but I don't think
> forcing people to built the pnfs file layout just because they want nfs4.1
> features is an all that smart idea.

IMHO it should be fine.

Most people will be compiling NFS as a module, in which case, the pnfs
file layout is just another module that can be left out from the final
binary if people don't want it.

I'm still waiting to hear from people who want to compile NFSv4.1 in the
main kernel, but who want pNFS to be modularised.

Cheers
  Trond
