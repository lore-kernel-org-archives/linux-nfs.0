From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
	flushing
Date: Mon, 1 Jun 2009 18:30:08 -0400
Message-ID: <20090601223008.GF5950@fieldses.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com> <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com> <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org> <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com> <1243615595.7155.48.camel@heimdal.trondhjem.org> <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com> <1243618500.7155.56.camel@heimdal.trondhjem.org> <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com> <20090530075756.GA27885@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>,
	Christoph Hellwig <hch@infradead.org>
To: Krishna Kumar <krikku@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38434 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbZFAWaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2009 18:30:13 -0400
In-Reply-To: <20090530075756.GA27885@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 30, 2009 at 03:57:56AM -0400, Christoph Hellwig wrote:
> On Sat, May 30, 2009 at 10:22:58AM +1000, Greg Banks wrote:
> >  * The underlying filesystem might be doing more or better things in
> > one or the other code paths e.g. optimising allocations.
> 
> Which is the case with ext3 which is pretty common.  It does reasonably
> well on O_SYNC as far as I can see, but has a catastrophic fsync
> implementation. 
> 
> >  * The Linux NFS server ignores the byte range in the COMMIT rpc and
> > flushes the whole file (I suspect this is a historical accident rather
> > than deliberate policy).  If there is other dirty data on that file
> > server-side, that other data will be written too before the COMMIT
> > reply is sent.  This may have a performance impact, depending on the
> > workload.
> 
> Right now we can't actually implement that proper because the fsync
> file operation can't actually flush sub ranges.  There have been some
> other requests for this, but my ->fsync resdesign in on hold until
> NFSD stops calling ->fsync without a file struct.
> 
> I think the open file cache will help us with that, if we can extend
> it to also cache open file structs for directories.

Krishna Kumar--do you think that'd be a reasonable thing to do?

--b.
