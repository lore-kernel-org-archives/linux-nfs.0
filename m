From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 05 Jun 2009 12:12:08 -0400
Message-ID: <1244218328.5410.38.camel@heimdal.trondhjem.org>
References: <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <20090530075756.GA27885@infradead.org> <20090601223008.GF5950@fieldses.org>
	 <20090605145450.GA11988@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Krishna Kumar <krikku@gmail.com>, Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>,
	Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55411 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbZFEQM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 12:12:27 -0400
In-Reply-To: <20090605145450.GA11988@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-06-05 at 10:54 -0400, Christoph Hellwig wrote:
> On Mon, Jun 01, 2009 at 06:30:08PM -0400, J. Bruce Fields wrote:
> > > NFSD stops calling ->fsync without a file struct.
> > > 
> > > I think the open file cache will help us with that, if we can extend
> > > it to also cache open file structs for directories.
> > 
> > Krishna Kumar--do you think that'd be a reasonable thing to do?
> 
> Btw, do you have at least the basic open files cache queue for 2.6.31?
> 

Now that _will_ badly screw up the write gathering heuristic...

Trond

