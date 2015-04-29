Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966103AbbD2OQO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 10:16:14 -0400
Date: Wed, 29 Apr 2015 10:16:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/6] nfsd: take struct file setup fully into
 nfs4_preprocess_stateid_op
Message-ID: <20150429141613.GA16016@fieldses.org>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
 <1430228480-7656-6-git-send-email-hch@lst.de>
 <20150428204455.GC16090@fieldses.org>
 <20150429131148.GA3381@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150429131148.GA3381@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 03:11:48PM +0200, Christoph Hellwig wrote:
> On Tue, Apr 28, 2015 at 04:44:55PM -0400, J. Bruce Fields wrote:
> > This causes a failure on pynfs OPEN23b.
> 
> I've once again tried to run pynfs, but I'm still errors out with weird
> python backtraces for any of the examples from the readme I copy
> and pasted, e.g.:
> 
> root@vm:~/pynfs/nfs4.0# ./testserver.py 127.0.0.1:/mnt/test --maketree all
> Initialization failed, no tests run.
> Traceback (most recent call last):
>   File "./testserver.py", line 379, in <module>
>     main()
>   File "./testserver.py", line 342, in main
>     env.init()
>   File "/root/pynfs/nfs4.0/servertests/environment.py", line 140, in init
>     self._maketree()
>   File "/root/pynfs/nfs4.0/servertests/environment.py", line 159, in _maketree
>     "Could not LOOKUP /%s," % '/'.join(path))
>   File "/root/pynfs/nfs4.0/servertests/environment.py", line 274, in checklist
>     raise testmod.FailureException(msg)
> testmod.FailureException: Could not LOOKUP /mnt, should return NFS4_OK or NFS4ERR_NOENT, instead got NFS4ERR_PERM

You probably just need to add "insecure" to the export.

(Every now and then we talk about changing that default.  The security
model there assumed you have untrusted users, but trusted root on every
machine on your network.  So the fact that a connection came from a low
port was enough to trust it.  That assumption seems fragile.  I don't
know if it's still a common setup.)

> > It's doing a READ using a stateid from a write open.  We previously
> > returned NFS_OK, taking the "may" option from:
> > 
> > 	http://tools.ietf.org/html/rfc7530#page-111
> > 
> > 	In the case of READ, the server may perform the corresponding
> > 	check on the access mode, or it may choose to allow READ on
> > 	opens for WRITE only, to accommodate clients whose write
> > 	implementation may unavoidably do reads (e.g., due to buffer
> > 	cache constraints).
> > 
> > OPENMODE might also have been OK, but we're returning SERVERFAULT.  I
> > guess the old code was passing preprocess_stateid_op without returning a
> > file, then relying on a temporary open for the read?  Ugh.
> 
> Looks like it.  I can change it to return an OPENMODE, or we could
> make it fall back to a temp read open.

I don't know if anyone actually behaves as described in the spec, but
for now I'd rather be conservative and keep the old behavior.  (So, yes,
fall back on a temporary read open.)

--b.
