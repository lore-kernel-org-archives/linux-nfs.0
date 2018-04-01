Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:40352 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753943AbeDAWUG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Apr 2018 18:20:06 -0400
Date: Sun, 1 Apr 2018 15:20:03 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        syzbot <syzbot+f3bd89a5ab3266b10540@syzkaller.appspotmail.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller-bugs@googlegroups.com, linux-nfs@vger.kernel.org
Subject: Re: BUG: corrupted list in __dentry_kill
Message-ID: <20180401222003.GU13332@bombadil.infradead.org>
References: <001a11447acaa9eec40568bd5438@google.com>
 <20180401033519.GZ30522@ZenIV.linux.org.uk>
 <20180401200531.GA30522@ZenIV.linux.org.uk>
 <20180401210508.GA743@sol.localdomain>
 <20180401214854.GB743@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180401214854.GB743@sol.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 01, 2018 at 02:48:54PM -0700, Eric Biggers wrote:
> list_del corruption. prev->next should be 000000002c929de0, but was 0000000065421b2c

Shuold probably try applying this; we might get a better clue about
the corruption.

diff --git a/lib/list_debug.c b/lib/list_debug.c
index a34db8d27667..5d5424b51b74 100644
--- a/lib/list_debug.c
+++ b/lib/list_debug.c
@@ -21,13 +21,13 @@ bool __list_add_valid(struct list_head *new, struct list_head *prev,
 		      struct list_head *next)
 {
 	if (CHECK_DATA_CORRUPTION(next->prev != prev,
-			"list_add corruption. next->prev should be prev (%p), but was %p. (next=%p).\n",
+			"list_add corruption. next->prev should be prev (%px), but was %px. (next=%px).\n",
 			prev, next->prev, next) ||
 	    CHECK_DATA_CORRUPTION(prev->next != next,
-			"list_add corruption. prev->next should be next (%p), but was %p. (prev=%p).\n",
+			"list_add corruption. prev->next should be next (%px), but was %px. (prev=%px).\n",
 			next, prev->next, prev) ||
 	    CHECK_DATA_CORRUPTION(new == prev || new == next,
-			"list_add double add: new=%p, prev=%p, next=%p.\n",
+			"list_add double add: new=%px, prev=%px, next=%px.\n",
 			new, prev, next))
 		return false;
 
@@ -43,16 +43,16 @@ bool __list_del_entry_valid(struct list_head *entry)
 	next = entry->next;
 
 	if (CHECK_DATA_CORRUPTION(next == LIST_POISON1,
-			"list_del corruption, %p->next is LIST_POISON1 (%p)\n",
+			"list_del corruption, %px->next is LIST_POISON1 (%px)\n",
 			entry, LIST_POISON1) ||
 	    CHECK_DATA_CORRUPTION(prev == LIST_POISON2,
-			"list_del corruption, %p->prev is LIST_POISON2 (%p)\n",
+			"list_del corruption, %px->prev is LIST_POISON2 (%px)\n",
 			entry, LIST_POISON2) ||
 	    CHECK_DATA_CORRUPTION(prev->next != entry,
-			"list_del corruption. prev->next should be %p, but was %p\n",
+			"list_del corruption. prev->next should be %px, but was %px\n",
 			entry, prev->next) ||
 	    CHECK_DATA_CORRUPTION(next->prev != entry,
-			"list_del corruption. next->prev should be %p, but was %p\n",
+			"list_del corruption. next->prev should be %px, but was %px\n",
 			entry, next->prev))
 		return false;
 
