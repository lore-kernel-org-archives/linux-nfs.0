Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:55462 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376AbZGNUhT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2009 16:37:19 -0400
Date: Tue, 14 Jul 2009 16:36:40 -0400
Message-Id: <200907142036.n6EKaexe017464@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
To: Valerie Aurora <vaurora@redhat.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, Jan Blunck <jblunck@suse.de>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: Union mounts, NFS, and locking 
In-reply-to: Your message of "Tue, 14 Jul 2009 16:19:41 EDT."
             <20090714201940.GF27582@shell>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In message <20090714201940.GF27582@shell>, Valerie Aurora writes:
> On Tue, Jul 14, 2009 at 02:19:26PM -0400, Erez Zadok wrote:
> > In message <20090714174828.GE27582@shell>, Valerie Aurora writes:
[...]
> > IMHO it's not worth at this stage to try and solve that problem in an
> > end-to-end manner (client to server).  For a unioning layer to have to worry
> > about every possible change in any of the layers below it, is no different
> > than for every possible network-filesystem client to be able to guarantee
> > that nothing ever changes on the server unexpectedly: they don't, so why
> > should you have to solve this problem now?  Not that I don't think it's an
> > important problem---I just don't see why *you* should have to solve this and
> > not the network-filesystem community: whatever solution that can come up,
> > can be applicable to any unioning layer.  In the mean time, do the best you
> > can (e.g., ESTALE, readonly superblocks, etc.).
> 
> Okay, so my best idea for a solution is to introduce a new NFS mount
> option that means the server promises that the exported file system is
> read-only (using superblock read-only count scheme locally).  E.g.:

How would the server be able to guarantee that?  Are you planning to change
the protocol or implementation somehow?  Are you assuming that the server
will be running linux w/ special r/o sb support?  If so, it won't work on
other platforms (NFS is supposed to be interoperable in principle :-)

Without a protocol change, such an option (if I understood you), is at best
a server promise to "behave nice."

In dealing with Unionfs, I've already had to face some really annoying
cases related to this.  For example, when the client mounts read-write, but
the server does *any* combination of these two:

1. export readonly or readwrite
2. the native f/s exported can be locally mounted r/o or r/w.

Turns out that servers in that case will return any of EROFS, EACESS, EPERM,
and even ESTALE.  So this is annoying to have to detect: a true permission
error should be returned to the user in unionfs, but a readonly access
should result in a copyup.  I don't believe this behavior was standardized
in v2/v3.

So, in retrospect, it would be *great* if I had a client-side mount option
that could guarantee that the server is exporting/mounting readonly.  But I
feel that for such a client-side option to work, some sort of information
has to flow b/t the server and the client to validate this readonly
assertion.

> /etc/exports:
> /client_root_fs   thin-client-*.local.domain(server_ro,no_root_squash)
> 
> Trond, is this super-gross or totally reasonable?  Seems like we add
> new NFS mount options at the drop of a hat.
> 
> -VAL

Erez.
