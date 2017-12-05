Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:55472 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751362AbdLEV2u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 16:28:50 -0500
Date: Tue, 5 Dec 2017 13:28:48 -0800
From: Matthew Wilcox <willy@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: Thiago Rafael Becker <thiago.becker@gmail.com>,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of
 set_groups.
Message-ID: <20171205212847.GF26021@bombadil.infradead.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171130130457.11429-3-thiago.becker@gmail.com>
 <87mv2ztgix.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
 <87efoatfsb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87efoatfsb.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 05, 2017 at 07:11:00AM +1100, NeilBrown wrote:
> As we don't seem to be pursuing this possibility is probably isn't very
> important, but I'd like to point out that the original fix isn't a true
> fix.
> It just sorts a shared group_info early.  This does not stop corruption.
> Every time a thread calls set_groups() on that group_info it will be
> sorted again.
> The sort algorithm used is the heap sort, and a heap sort always moves
> elements in the array around - it does not leave a sorted array
> untouched (unlike e.g. the quick sort which doesn't move anything in a
> sorted array).
> So it is still possible for two calls to groups_sort() to race.
> We *need* to move groups_sort() out of set_groups().

It must be relatively common to sort an already-sorted array.  I wonder
if something like this patch would be worthwhile?

I have deliberately broken this patch so it can't be applied.  I haven't
tested it, and for all I know, I got the sign of cmp_func wrong.

diff --git a/lib/sort.c b/lib/sort.c
index d6b7a202b0b6..2b527fde6dad 100644
--- a/lib/sort.c
+++ b/lib/sort.c
@@ -75,7 +75,14 @@ void sort(void *base, size_t num, size_t size,
 			swap_func = generic_swap;
 	}
 
-       /* heapify */
+	/* Do not sort an already-sorted array */
+	for (c = 0; c < (n - size); c += size) {
+		if (cmp_func(base + c, base + c + size) < 0)
+			goto heapify;
+	}
+	return;
+
+heapify:
 	for ( ; i >= 0; i -= size) {
 		for (r = i; r * 2 + size < n; r  = c) {
 			c = r * 2 + size;


