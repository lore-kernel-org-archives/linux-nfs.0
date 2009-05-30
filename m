From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Sat, 30 May 2009 08:26:03 -0400
Message-ID: <1243686363.5209.16.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57023 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325AbZE3M0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 May 2009 08:26:11 -0400
In-Reply-To: <ac442c870905291722x1ec811b2sda997d464898fcda-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-05-30 at 10:22 +1000, Greg Banks wrote:
> On Sat, May 30, 2009 at 3:35 AM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2009-05-29 at 13:25 -0400, Brian R Cowan wrote:
> >>
> >
> > What are you smoking? There is _NO_DIFFERENCE_ between what the server
> > is supposed to do when sent a single stable write, and what it is
> > supposed to do when sent an unstable write plus a commit. BOTH cases are
> > supposed to result in the server writing the data to stable storage
> > before the stable write / commit is allowed to return a reply.
> 
> This probably makes no difference to the discussion, but for a Linux
> server there is a subtle difference between what the server is
> supposed to do and what it actually does.
> 
> For a stable WRITE rpc, the Linux server sets O_SYNC in the struct
> file during the vfs_writev() call and expects the underlying
> filesystem to obey that flag and flush the data to disk.  For a COMMIT
> rpc, the Linux server uses the underlying filesystem's f_op->fsync
> instead.  This results in some potential differences:
> 
>  * The underlying filesystem might be broken in one code path and not
> the other (e.g. ignoring O_SYNC in f_op->{aio_,}write or silently
> failing in f_op->fsync).  These kinds of bugs tend to be subtle
> because in the absence of a crash they affect only the timing of IO
> and so they might not be noticed.
> 
>  * The underlying filesystem might be doing more or better things in
> one or the other code paths e.g. optimising allocations.
> 
>  * The Linux NFS server ignores the byte range in the COMMIT rpc and
> flushes the whole file (I suspect this is a historical accident rather
> than deliberate policy).  If there is other dirty data on that file
> server-side, that other data will be written too before the COMMIT
> reply is sent.  This may have a performance impact, depending on the
> workload.
> 
> > The extra RPC round trip (+ parsing overhead ++++) due to the commit
> > call is the _only_ difference.
> 
> This is almost completely true.  If the server behaved ideally and
> predictably, this would be completely true.
> 
> </pedant>
> 

Firstly, the server only uses O_SYNC if you turn off write gathering
(a.k.a. the 'wdelay' option). The default behaviour for the Linux nfs
server is to always try write gathering and hence no O_SYNC.

Secondly, even if it were the case, then this does not justify changing
the client behaviour. The NFS protocol does not mandate, or even
recommend that the server use O_SYNC. All it says is that a stable write
and an unstable write+commit should both have the same result: namely
that the data+metadata must have been flushed to stable storage. The
protocol spec leaves it as an exercise to the server implementer to do
this as efficiently as possible.


  Trond

