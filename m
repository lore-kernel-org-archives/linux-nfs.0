Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34934 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab2FEP7T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 11:59:19 -0400
Message-ID: <4FCE2CCE.9000900@openvz.org>
Date: Tue, 05 Jun 2012 19:59:10 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
CC: Ondrej Zary <linux@rainbow-software.org>, Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        =?ISO-8859-1?Q?Toralf_F=F6r?= =?ISO-8859-1?Q?ster?=
	<toralf.foerster@gmx.de>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org> <4FCE1D17.1080904@openvz.org> <87zk8h23wn.fsf@devron.myhome.or.jp> <4FCE2256.7010804@openvz.org>
In-Reply-To: <4FCE2256.7010804@openvz.org>
Content-Type: multipart/mixed;
 boundary="------------080706050900010906060105"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080706050900010906060105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Proper fix in attachment.

Konstantin Khlebnikov wrote:
> OGAWA Hirofumi wrote:
>> Konstantin Khlebnikov<khlebnikov@openvz.org>   writes:
>>
>>> Hmm, very interesting!
>>> Please try this patch, it must fix the problem and print some numbers to debug.
>>>
>>
>> I think the bug is in radix_tree_for_each_contig().
>>
>> radix_tree_next_slot() returns NULL if the slot was NULL (i.e. there is
>> hole). But, slot == NULL is not meaning to stop iterate here. Actually,
>> if slot is NULL, it gets next chunk.
>>
>> Bang.
>
> Yeah, you are right, I already found this too.
> Currently I think how to fix this more accurately...
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--------------080706050900010906060105
Content-Type: text/plain;
 name="radix-tree-fix-contiguous-iterator"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="radix-tree-fix-contiguous-iterator"

radix-tree: fix contiguous iterator

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

This patch fixes bug in macro radix_tree_for_each_contig().
If radix_tree_next_slot() sees NULL in next slot it returns NULL, but following
radix_tree_next_chunk() switches iterating into next chunk. As result iterating
becomes non-contiguous and breaks vfs "splice" and all its users.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reported-and-bisected-by: Hans de Bruin <jmdebruin@xmsnet.nl>
Reported-and-bisected-by: Ondrej Zary <linux@rainbow-software.org>
Reported-and-bisected-by: Toralf Förster <toralf.foerster@gmx.de>
---
 include/linux/radix-tree.h |    5 ++++-
 lib/radix-tree.c           |    3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 0d04cd6..ffc444c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -368,8 +368,11 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 			iter->index++;
 			if (likely(*slot))
 				return slot;
-			if (flags & RADIX_TREE_ITER_CONTIG)
+			if (flags & RADIX_TREE_ITER_CONTIG) {
+				/* forbid switching to the next chunk */
+				iter->next_index = 0;
 				break;
+			}
 		}
 	}
 	return NULL;
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 86516f5..3ac50dc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -673,6 +673,9 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	 * during iterating; it can be zero only at the beginning.
 	 * And we cannot overflow iter->next_index in a single step,
 	 * because RADIX_TREE_MAP_SHIFT < BITS_PER_LONG.
+	 *
+	 * This condition also used by radix_tree_next_slot() to stop
+	 * contiguous iterating, and forbid swithing to the next chunk.
 	 */
 	index = iter->next_index;
 	if (!index && iter->index)

--------------080706050900010906060105--
