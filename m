Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:44951 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab1G3D0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 23:26:23 -0400
Date: Fri, 29 Jul 2011 23:26:21 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110730032621.GB25188@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <20110729155136.GB28306@infradead.org>
 <20110729185415.GA23061@merit.edu>
 <20110729190133.GA10946@infradead.org>
 <20110729191341.GC23061@merit.edu>
 <1311988172.16078.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311988172.16078.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  >   Looks like we did find a bug in NFS.
  > 
  > It kind of looks that way.
  
  Is that reproducible on the upstream kernel, or is it something that is
  being introduced by the pNFS blocks code?

It happens without the blocks module loaded, but it could be from something
we did outside the module.  I will test this weekend when I get a chance.
