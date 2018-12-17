Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEAAAC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 18:55:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6490D20874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 18:55:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726628AbeLQSzT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 13:55:19 -0500
Received: from laurent.telenet-ops.be ([195.130.137.89]:59498 "EHLO
        laurent.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728282AbeLQSzT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 13:55:19 -0500
Received: from ramsan ([84.194.111.163])
        by laurent.telenet-ops.be with bizsmtp
        id D6vD1z00R3XaVaC016vDK1; Mon, 17 Dec 2018 19:55:16 +0100
Received: from rox.of.borg ([192.168.97.57])
        by ramsan with esmtp (Exim 4.90_1)
        (envelope-from <geert@linux-m68k.org>)
        id 1gYy2r-00045Q-D1; Mon, 17 Dec 2018 19:55:13 +0100
Received: from geert by rox.of.borg with local (Exim 4.90_1)
        (envelope-from <geert@linux-m68k.org>)
        id 1gYy2r-0005zV-Ai; Mon, 17 Dec 2018 19:55:13 +0100
From:   Geert Uytterhoeven <geert@linux-m68k.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     Alexander Viro <viro@zeniv.linux.org.uk>,
        Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
        Ralf Baechle <ralf@linux-mips.org>,
        Paul Burton <paul.burton@mips.com>,
        James Hogan <jhogan@kernel.org>, linux-nfs@vger.kernel.org,
        linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
Date:   Mon, 17 Dec 2018 19:55:06 +0100
Message-Id: <20181217185506.22976-1-geert@linux-m68k.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <f322eb9ee0cac75f98d188b46843c2df00485f35.camel@hammerspace.com>
References: <f322eb9ee0cac75f98d188b46843c2df00485f35.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

	Hi Trond,

(For the newly added CCs, first message was
https://lore.kernel.org/lkml/CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com/)

> On Mon, Dec 17, 2018 at 3:51 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
> > On Mon, 2018-12-17 at 15:03 +0100, Geert Uytterhoeven wrote:
> > > On Wed, Dec 5, 2018 at 3:47 PM Geert Uytterhoeven <
> > > geert@linux-m68k.org> wrote:
> > > > On Wed, Dec 5, 2018 at 2:45 PM Trond Myklebust <
> > > > trondmy@hammerspace.com> wrote:
> > > > > On Wed, 2018-12-05 at 14:41 +0100, Geert Uytterhoeven wrote:
> > > > > > On Wed, Dec 5, 2018 at 2:11 PM Atsushi Nemoto <
> > > > > > anemo@mba.ocn.ne.jp>
> > > > > > wrote:
> > > > > > > On Tue, 4 Dec 2018 14:53:07 +0100, Geert Uytterhoeven <
> > > > > > > geert@linux-m68k.org> wrote:
> > > > > > > > I found similar crashes in a report from 2006, but of
> > > > > > > > course the
> > > > > > > > code
> > > > > > > > has changed too much to apply the solution proposed there
> > > > > > > > (
> > > > > > > > https://www.linux-mips.org/archives/linux-mips/2006-09/msg00169.html
> > > > > > > > ).
> > > > > > > >
> > > > > > > > Userland is Debian 8 (the last release supporting "old"
> > > > > > > > MIPS).
> > > > > > > > My kernel is based on v4.20.0-rc5, but the issue happens
> > > > > > > > with
> > > > > > > > v4.20-rc1,
> > > > > > > > too.
> > > > > > > >
> > > > > > > > However, I noticed it works in v4.19! Hence I've bisected
> > > > > > > > this,
> > > > > > > > to commit
> > > > > > > > 277e4ab7d530bf28 ("SUNRPC: Simplify TCP receive code by
> > > > > > > > switching
> > > > > > > > to using
> > > > > > > > iterators").
> > > > > > > >
> > > > > > > > Dropping the ",tcp" part from the nfsroot parameter also
> > > > > > > > fixes
> > > > > > > > the issue.
> > > > > > > >
> > > > > > > > Given RBTX4927 is little endian, just like my arm/arm64
> > > > > > > > boards,
> > > > > > > > it's probably
> > > > > > > > not an endianness issue.  Sparse didn't show anything
> > > > > > > > suspicious
> > > > > > > > before/after
> > > > > > > > the guilty commit.
> > > > > > > >
> > > > > > > > Do you have a clue?
> > > > > > >
> > > > > > > If it was a cache issue, disabling i-cache or d-cache
> > > > > > > completely
> > > > > > > might
> > > > > > > help understanding the problem.  I added TXx9 specific
> > > > > > > "icdisable"
> > > > > > > and
> > > > > > > "dcdisable" kernel options for debugging long ago.
> > > > > > >
> > > > > > > I hope these options still works correctly with recent kernel
> > > > > > > but
> > > > > > > not
> > > > > > > sure.
> > > > > > >
> > > > > > > Also, disabling i-cache makes your board VERY slow, of
> > > > > > > course.
> > > > > >
> > > > > > Thanks!
> > > > > >
> > > > > > When using these options, I do see a slowdown in early boot,
> > > > > > but the
> > > > > > issue
> > > > > > is still there.
> > > > > >
> > > > > > My next guess is an unaligned access not using
> > > > > > {get,put}_unaligned(),
> > > > > > which
> > > > > > doesn't seem to work on tx4927, but doesn't cause an exception
> > > > > > neither.
> > > > >
> > > > > Can you try my linux-next branch on git.linux-nfs.org? It
> > > > > contains a
> > > > > fixes for a hang that results from the above commit.
> > > > >
> > > > > git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
> > > > > linux-next
> > > >
> > > > Thanks for the suggestion, but unfortunately it doesn't help.
> > >
> > > In the mean time, I tried your newer linux-next, no change.
> > > I tried several other things:
> > >   - remove the packed attribute (why did you add that?),
> >
> > The packed attribute allows us to avoid a series of copy operations
> > when decoding the first three elements of a RPC over TCP header (which
> > is why they are all declared as big endian). The alternative would be
> > to have a 12 byte buffer there for temporary storage, and then a
> > duplicate set of 3 32-bit words into which we copy the buffer contents
> > after extracting them from the (non-blocking) socket.
> >
> > >   - verify (at runtime) that all accesses to fraghdr, xid, and
> > > calldir
> > > are aligned,
> > >   - enable RPC_DEBUG_DATA, nothing fishy seen at first sight.
> > >
> > > Is anyone else seeing this on MIPS, or any other platform?
> > > Does mounting NFS with -o nfsvers=3,tcp work on other MIPS platforms?
> >
> > I have no access to any MIPS hardware for the purposes of testing so
> > that would be a question for the community.
> >
> > One thing that I have noticed is that unlike the old code, the bvec
> > 'generic' code does appear to fail to call flush_dcache_page(). Could
> > that be causing the problem here? If so, why would that not be a
> > problem in the context of regular block I/O?

Thanks for the hint!

It wasn't clear to me where exactly the old code called
flush_dcache_page(), but as rpcrdma_inline_fixup() calls it in between
copying to a page, and unmapping the page, I added a call to
flush_dcache_page() to all functions in lib/iov_iter.c that map a page
and copy to it, cfr. the patch below.

And suddenly NFS root over TCP is working again!

Note that I have no idea if it affects regular block I/O, as my RBTX4927
does not have block devices.

Also note that this platform does not use highmem.

So, where's the proper place to fix this?
Thanks in advance!

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 54c248526b55fc49..5be62db33414d3f9 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -277,6 +277,7 @@ static size_t copy_page_from_iter_iovec(struct page *page, size_t offset, size_t
 			to += copy;
 			bytes -= copy;
 		}
+		flush_dcache_page(page);
 		if (likely(!bytes)) {
 			kunmap_atomic(kaddr);
 			goto done;
@@ -463,6 +464,7 @@ static void memcpy_to_page(struct page *page, size_t offset, const char *from, s
 {
 	char *to = kmap_atomic(page);
 	memcpy(to + offset, from, len);
+	flush_dcache_page(page);
 	kunmap_atomic(to);
 }
 
@@ -470,6 +472,7 @@ static void memzero_page(struct page *page, size_t offset, size_t len)
 {
 	char *addr = kmap_atomic(page);
 	memset(addr + offset, 0, len);
+	flush_dcache_page(page);
 	kunmap_atomic(addr);
 }
 
@@ -580,6 +583,7 @@ static size_t csum_and_copy_to_pipe_iter(const void *addr, size_t bytes,
 		char *p = kmap_atomic(pipe->bufs[idx].page);
 		next = csum_partial_copy_nocheck(addr, p + r, chunk, 0);
 		sum = csum_block_add(sum, next, off);
+		flush_dcache_page(pipe->bufs[idx].page);
 		kunmap_atomic(p);
 		i->idx = idx;
 		i->iov_offset = r + chunk;
@@ -628,6 +632,7 @@ static unsigned long memcpy_mcsafe_to_page(struct page *page, size_t offset,
 
 	to = kmap_atomic(page);
 	ret = memcpy_mcsafe(to + offset, from, len);
+	flush_dcache_page(page);
 	kunmap_atomic(to);
 
 	return ret;
@@ -894,6 +899,7 @@ size_t copy_page_from_iter(struct page *page, size_t offset, size_t bytes,
 	if (i->type & (ITER_BVEC|ITER_KVEC)) {
 		void *kaddr = kmap_atomic(page);
 		size_t wanted = _copy_from_iter(kaddr + offset, bytes, i);
+		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		return wanted;
 	} else
@@ -958,6 +964,7 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 				 v.bv_offset, v.bv_len),
 		memcpy((p += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
+	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 	return bytes;
 }
@@ -1494,6 +1501,7 @@ size_t csum_and_copy_to_iter(const void *addr, size_t bytes, __wsum *csum,
 		next = csum_partial_copy_nocheck((from += v.bv_len) - v.bv_len,
 						 p + v.bv_offset,
 						 v.bv_len, 0);
+		flush_dcache_page(v.bv_page);
 		kunmap_atomic(p);
 		sum = csum_block_add(sum, next, off);
 		off += v.bv_len;

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
