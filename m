From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: atimes not updated over NFS
Date: Tue, 29 Jan 2008 19:30:42 +0100
Message-ID: <20080129183042.GH15220@kernel.dk>
References: <20080114175122.GB2768@janus> <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org> <20080129083402.GN15220@kernel.dk> <20080129182721.GB28032@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:1083 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbYA2Sar (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 13:30:47 -0500
In-Reply-To: <20080129182721.GB28032@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29 2008, J. Bruce Fields wrote:
> On Tue, Jan 29, 2008 at 09:34:02AM +0100, Jens Axboe wrote:
> > On Mon, Jan 28 2008, J. Bruce Fields wrote:
> > > On Mon, Jan 28, 2008 at 09:59:40PM -0500, bfields wrote:
> > > > On Tue, Jan 22, 2008 at 12:17:17PM -0500, bfields wrote:
> > > > > On Mon, Jan 21, 2008 at 04:09:25PM -0500, bfields wrote:
> > > > > > On Mon, Jan 21, 2008 at 10:02:30PM +0100, Frank van Maarseveen wrote:
> > > > > > > 2.6.22.10:
> > > > > > > 	t
> > > > > > > 	t + 2
> > > > > > > 	t + 2
> > > > > > > 
> > > > > > > (same behavior)
> > > > > > > 
> > > > > > > 2.6.23.12:
> > > > > > > 	t
> > > > > > > 	t
> > > > > > > 	t
> > > > > > > 
> > > > > > > definately not good. "cat" on the server updates atime again.
> > > > > > 
> > > > > > Yes, that looks like a server bug, and this:...
> > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > Trying a different combination of kernels:
> > > > > > > 
> > > > > > > server 2.6.23.12, client 2.6.22.10:
> > > > > > > 	t
> > > > > > > 	t
> > > > > > > 	t
> > > > > > > 
> > > > > > > server 2.6.22.10, client 2.6.23.12:
> > > > > > > 	t
> > > > > > > 	t + 2
> > > > > > > 	t + 2
> > > > > > 
> > > > > > ...confirms that since the results appear to depend only on the server
> > > > > > version, not on the client version.
> > > > > 
> > > > > And I can confirm this here on 2.6.24-rc8 (+ a few patches).
> > > > > Unfortunately, I don't have any suggestion better right now than
> > > > > bisecting....
> > > > 
> > > > It looks like this happened in the switch from sendfile to sparse.
> > > 							     ^^^^^^
> > > 							err, splice
> > > 
> > > > Jens, any advice?  What happened was nfsd reads stopped updating the
> > > > atime after the following commit.
> > > 
> > > Erm, sorry, wrong commit--it's the following one that touches nfsd,
> > > below.
> > 
> > Probably because do_generic_mapping_read() does a file_accessed() on the
> > input file. Does this fixup current -git?
> 
> No, nfsd is calling splice_direct_to_actor(), not do_splice_direct().

Ah doh, this instead then. Should work for both types.

diff --git a/fs/splice.c b/fs/splice.c
index 0a0b79b..504a096 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1052,8 +1052,10 @@ out_release:
 	/*
 	 * If we transferred some data, return the number of bytes:
 	 */
-	if (bytes > 0)
+	if (bytes > 0) {
+		file_accessed(in);
 		return bytes;
+	}
 
 	return ret;
 

-- 
Jens Axboe

