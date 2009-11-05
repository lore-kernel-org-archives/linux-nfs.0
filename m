From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related
 headers
Date: Thu, 05 Nov 2009 09:06:33 -0800
Message-ID: <1257440793.3114.8.camel@heimdal.trondhjem.org>
References: <1256112873-32495-1-git-send-email-bharrosh@panasas.com>
	 <1256171298.6809.1.camel@heimdal.trondhjem.org>
	 <4AE01569.9000002@panasas.com>
	 <1256220146.6402.23.camel@heimdal.trondhjem.org>
	 <4AE08165.2040100@panasas.com> <20091104220927.GS11637@fieldses.org>
	 <4AF2914F.60803@panasas.com> <20091105163333.GB29981@fieldses.org>
	 <20091105164145.GC29981@fieldses.org>
	 <1257440343.3114.7.camel@heimdal.trondhjem.org>
	 <20091105170310.GE29981@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	Benny Halevy <bhalevy@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56730 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153AbZKERGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 12:06:32 -0500
In-Reply-To: <20091105170310.GE29981@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-11-05 at 12:03 -0500, J. Bruce Fields wrote:
> On Thu, Nov 05, 2009 at 08:59:02AM -0800, Trond Myklebust wrote:
> > On Thu, 2009-11-05 at 11:41 -0500, J. Bruce Fields wrote:
> > > By the way, along the lines of your .h moves, while looking at steved's
> > > export stuff I was reminded again of how much in include/linux/nfsd is
> > > really internal to nfsd, so I'm thinking of committing this.
> > 
> > Right. Most of the NFS client include files should really be moved into
> > fs/nfs rather than into a new directory in include/linux.
> 
> On the server side my greatest source of confusion here is some includes
> of nfsd headers in arch-specific code.  Was it needed for some sort of
> compatibility glue for the nfsservctl system call, maybe?  I've never
> figured it out.

Possibly for the 32-bit emulation code on 64-bit systems?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
