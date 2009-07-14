From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: Union mounts, NFS, and locking
Date: Tue, 14 Jul 2009 18:33:27 -0400
Message-ID: <200907142233.n6EMXRQp019008@agora.fsl.cs.sunysb.edu>
References: <20090714220515.GH27582@shell>
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Valerie Aurora <vaurora@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:55710 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973AbZGNWeB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2009 18:34:01 -0400
In-reply-to: Your message of "Tue, 14 Jul 2009 18:05:16 EDT."
             <20090714220515.GH27582@shell>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20090714220515.GH27582@shell>, Valerie Aurora writes:
> On Tue, Jul 14, 2009 at 04:36:40PM -0400, Erez Zadok wrote:
> > In message <20090714201940.GF27582@shell>, Valerie Aurora writes:
> >
> > > Okay, so my best idea for a solution is to introduce a new NFS mount
> > > option that means the server promises that the exported file system is
> > > read-only (using superblock read-only count scheme locally).  E.g.:
> > 
> > How would the server be able to guarantee that?  Are you planning to change
> > the protocol or implementation somehow?  Are you assuming that the server
> > will be running linux w/ special r/o sb support?  If so, it won't work on
> > other platforms (NFS is supposed to be interoperable in principle :-)
> > 
> > Without a protocol change, such an option (if I understood you), is at best
> > a server promise to "behave nice."
> 
> Yeah, it's just a promise, one that the NFS server shouldn't make if
> it can't implement it.  The client's sole responsibility is to fail
> gracefully if the server breaks its promise.
[...]

How would the client detect that the server broke the promise?  In theory,
your client may never know b/c it'll never send the server any
state-changing ops (e.g., creat, write, unlink).  One really ugly idea might
be for the client to try and create a dummy .nfsXXXXXX file on the server,
and if that succeds, or the error returned isn't EROFS, the client can guess
that the server's misbhaving.

Erez.
