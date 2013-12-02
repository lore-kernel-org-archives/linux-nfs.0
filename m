Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221Ab3LBQu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 11:50:56 -0500
Date: Mon, 2 Dec 2013 11:50:53 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Charles 'Boyo" <charlesboyo@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Questions abou nfsd file cache and open files
Message-ID: <20131202165053.GB1971@pad.fieldses.org>
References: <CAPD_G3JioWUiBJD-SMZeMgQd40DarVV_bYAnggQKgWLi3bQPCw@mail.gmail.com>
 <B6FEA9E5-5DAC-4087-97D7-C3BC610EA792@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B6FEA9E5-5DAC-4087-97D7-C3BC610EA792@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 11:46:32AM -0500, Chuck Lever wrote:
> Hi-
> 
> Questions about NFSD should go to Bruce Fields (copied), the Linux NFS server maintainer.
> 
> 
> On Nov 29, 2013, at 6:21 AM, Charles 'Boyo <charlesboyo@gmail.com> wrote:
> 
> > Hello all.
> > 
> > Please guide me into to find out the impact a busy nfsd is having on
> > the Linux page cache. Is it possible to determine which files have
> > portions in the page cache?
> 
> That is not possible even for local files, AFAIK.  (/me prepares to eat his words).

Right.  Sounds like an interesting research project....

> > Secondly, files opened by nfs clients do not show up in lsof (or ftop)
> > on the nfs server? Is there any way to list these open files and more
> > importantly, observe the i/o to them?
> 
> 
> NFSv3 does not have an OPEN operation.  It would be difficult to tell, accurately, what an NFSv3 client was up to by looking for open files on an NFS server.
> 
> NFSv4 does perform file OPENs on the wire, but our I/O metrics are per-NFS operation, not per-file.  So you can see how many READs and WRITEs are done in aggregate, but not by which client, and not for a particular file.
> 
> NFSv4 also has delegation, which allows clients to operate on files without contacting the NFS server.  I/O activity that is cached by a client would not be visible to the storage server in any way.

Yes.  We could (and really should) have some statistics/debugging
interfaces to expose information like which clients currently hold NFSv4
opens, but we don't currently.

--b.
