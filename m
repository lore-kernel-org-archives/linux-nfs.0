From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 14:21:00 -0400
Message-ID: <1243621260.7155.91.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <4A202009.4010202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38596 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753550AbZE2SVJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 14:21:09 -0400
In-Reply-To: <4A202009.4010202@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 13:48 -0400, Peter Staubach wrote:
> Trond Myklebust wrote:
> > Look... This happens when you _flush_ the file to stable storage if
> > there is only a single write < wsize. It isn't the business of the NFS
> > layer to decide when you flush the file; that's an application
> > decision...
> >
> >   
> 
> I think that one easy way to show why this optimization is
> not quite what we would all like, why there only being a
> single write _now_ isn't quite sufficient, is to write a
> block of a file and then read it back.  Things like
> compilers and linkers might do this during their random
> access to the file being created.  I would guess that this
> audit thing that Brian has refered to does the same sort
> of thing.
> 
>        ps
> 
> ps. Why do we flush dirty pages before they can be read?
> I am not even clear why we care about waiting for an
> already existing flush to be completed before using the
> page to satisfy a read system call.

We only do this if the page cannot be marked as up to date. i.e. there
have to be parts of the page which contain valid data on the server, and
that our client hasn't read in yet, and that aren't being overwritten by
our write.

Trond

