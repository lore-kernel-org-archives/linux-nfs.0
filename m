From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: atimes not updated over NFS
Date: Tue, 29 Jan 2008 09:34:02 +0100
Message-ID: <20080129083402.GN15220@kernel.dk>
References: <20080114083435.GA24215@janus> <1200325393.7470.6.camel@heimdal.trondhjem.org> <20080114175122.GB2768@janus> <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:11667 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296AbYA2IeF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 03:34:05 -0500
In-Reply-To: <20080129041411.GC1190@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28 2008, J. Bruce Fields wrote:
> On Mon, Jan 28, 2008 at 09:59:40PM -0500, bfields wrote:
> > On Tue, Jan 22, 2008 at 12:17:17PM -0500, bfields wrote:
> > > On Mon, Jan 21, 2008 at 04:09:25PM -0500, bfields wrote:
> > > > On Mon, Jan 21, 2008 at 10:02:30PM +0100, Frank van Maarseveen wrote:
> > > > > 2.6.22.10:
> > > > > 	t
> > > > > 	t + 2
> > > > > 	t + 2
> > > > > 
> > > > > (same behavior)
> > > > > 
> > > > > 2.6.23.12:
> > > > > 	t
> > > > > 	t
> > > > > 	t
> > > > > 
> > > > > definately not good. "cat" on the server updates atime again.
> > > > 
> > > > Yes, that looks like a server bug, and this:...
> > > > 
> > > > > 
> > > > > 
> > > > > Trying a different combination of kernels:
> > > > > 
> > > > > server 2.6.23.12, client 2.6.22.10:
> > > > > 	t
> > > > > 	t
> > > > > 	t
> > > > > 
> > > > > server 2.6.22.10, client 2.6.23.12:
> > > > > 	t
> > > > > 	t + 2
> > > > > 	t + 2
> > > > 
> > > > ...confirms that since the results appear to depend only on the server
> > > > version, not on the client version.
> > > 
> > > And I can confirm this here on 2.6.24-rc8 (+ a few patches).
> > > Unfortunately, I don't have any suggestion better right now than
> > > bisecting....
> > 
> > It looks like this happened in the switch from sendfile to sparse.
> 							     ^^^^^^
> 							err, splice
> 
> > Jens, any advice?  What happened was nfsd reads stopped updating the
> > atime after the following commit.
> 
> Erm, sorry, wrong commit--it's the following one that touches nfsd,
> below.

Probably because do_generic_mapping_read() does a file_accessed() on the
input file. Does this fixup current -git?

diff --git a/fs/splice.c b/fs/splice.c
index 56b802b..c212fde 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1090,8 +1090,10 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 	long ret;
 
 	ret = splice_direct_to_actor(in, &sd, direct_splice_actor);
-	if (ret > 0)
+	if (ret > 0) {
 		*ppos += ret;
+		file_accessed(in);
+	}
 
 	return ret;
 }

-- 
Jens Axboe

