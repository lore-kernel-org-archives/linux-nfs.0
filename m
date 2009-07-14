From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: Union mounts, NFS, and locking
Date: Tue, 14 Jul 2009 18:05:16 -0400
Message-ID: <20090714220515.GH27582@shell>
References: <20090714201940.GF27582@shell> <200907142036.n6EKaexe017464@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196AbZGNWFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 18:05:34 -0400
In-Reply-To: <200907142036.n6EKaexe017464-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2009 at 04:36:40PM -0400, Erez Zadok wrote:
> In message <20090714201940.GF27582@shell>, Valerie Aurora writes:
>
> > Okay, so my best idea for a solution is to introduce a new NFS mount
> > option that means the server promises that the exported file system is
> > read-only (using superblock read-only count scheme locally).  E.g.:
> 
> How would the server be able to guarantee that?  Are you planning to change
> the protocol or implementation somehow?  Are you assuming that the server
> will be running linux w/ special r/o sb support?  If so, it won't work on
> other platforms (NFS is supposed to be interoperable in principle :-)
> 
> Without a protocol change, such an option (if I understood you), is at best
> a server promise to "behave nice."

Yeah, it's just a promise, one that the NFS server shouldn't make if
it can't implement it.  The client's sole responsibility is to fail
gracefully if the server breaks its promise.

The "protocol change" can probably be limited to a new NFS mount
option and the error returned if the server can't implement this mount
option.

> In dealing with Unionfs, I've already had to face some really annoying
> cases related to this.  For example, when the client mounts read-write, but
> the server does *any* combination of these two:
> 
> 1. export readonly or readwrite
> 2. the native f/s exported can be locally mounted r/o or r/w.
> 
> Turns out that servers in that case will return any of EROFS, EACESS, EPERM,
> and even ESTALE.  So this is annoying to have to detect: a true permission
> error should be returned to the user in unionfs, but a readonly access
> should result in a copyup.  I don't believe this behavior was standardized
> in v2/v3.
> 
> So, in retrospect, it would be *great* if I had a client-side mount option
> that could guarantee that the server is exporting/mounting readonly.  But I
> feel that for such a client-side option to work, some sort of information
> has to flow b/t the server and the client to validate this readonly
> assertion.

I'm glad it would be useful in other cases!

-VAL
