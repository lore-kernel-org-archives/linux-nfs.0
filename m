Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:56872 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab2CNDoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 23:44:39 -0400
Message-ID: <4F60141A.709@panasas.com>
Date: Tue, 13 Mar 2012 20:44:26 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs-obj: Uglify objio_segment allocation for the sake of
 the principle :-(
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


At some past instance Linus Trovalds wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> commit a84a79e4d369a73c0130b5858199e949432da4c6 upstream.
>
> The size is always valid, but variable-length arrays generate worse code
> for no good reason (unless the function happens to be inlined and the
> compiler sees the length for the simple constant it is).
>
> Also, there seems to be some code generation problem on POWER, where
> Henrik Bakken reports that register r28 can get corrupted under some
> subtle circumstances (interrupt happening at the wrong time?).  That all
> indicates some seriously broken compiler issues, but since variable
> length arrays are bad regardless, there's little point in trying to
> chase it down.
>
> "Just don't do that, then".

Since then any use of "variable length arrays" has become blasphemous.
Even in perfectly good, beautiful, perfectly safe code like the one
below where the variable length arrays are only used as a sizeof()
parameter, for type-safe dynamic structure allocations. GCC is not
executing any stack allocation code.

I have produced a small file which defines two functions main1(unsigned numdevs)
and main2(unsigned numdevs). main1 uses code as before with call to malloc
and main2 uses code as of after this patch. I compiled it as:
	gcc -O2 -S see_asm.c
and here is what I get:

<see_asm.s>
main1:
.LFB7:
	.cfi_startproc
	mov	%edi, %edi
	leaq	4(%rdi,%rdi), %rdi
	salq	$3, %rdi
	jmp	malloc
	.cfi_endproc
.LFE7:
	.size	main1, .-main1
	.p2align 4,,15
	.globl	main2
	.type	main2, @function
main2:
.LFB8:
	.cfi_startproc
	mov	%edi, %edi
	addq	$2, %rdi
	salq	$4, %rdi
	jmp	malloc
	.cfi_endproc
.LFE8:
	.size	main2, .-main2
	.section	.text.startup,"ax",@progbits
	.p2align 4,,15
</see_asm.s>

*Exact* same code !!!

So please seriously consider not accepting this patch and leave the
perfectly good code intact.

CC: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   39 +++++++++++++++++++++++++--------------
 1 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 55d0128..37a9269 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -205,25 +205,36 @@ static void copy_single_comp(struct ore_components *oc, unsigned c,
 int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
 		       struct objio_segment **pseg)
 {
-	struct __alloc_objio_segment {
-		struct objio_segment olseg;
-		struct ore_dev *ods[numdevs];
-		struct ore_comp	comps[numdevs];
-	} *aolseg;
-
-	aolseg = kzalloc(sizeof(*aolseg), gfp_flags);
-	if (unlikely(!aolseg)) {
+/*	This is the in memory structure of the objio_segment
+ *
+ *	struct __alloc_objio_segment {
+ *		struct objio_segment olseg;
+ *		struct ore_dev *ods[numdevs];
+ *		struct ore_comp	comps[numdevs];
+ *	} *aolseg;
+ *	NOTE: The code as above compiles and runs perfectly. It is elegant,
+ *	type safe and compact. At some Past time Linus has decided he does not
+ *	like variable length arrays, For the sake of this principal we uglify
+ *	the code as below.
+ */
+	struct objio_segment *lseg;
+	size_t lseg_size = sizeof(*lseg) +
+			numdevs * sizeof(lseg->oc.ods[0]) +
+			numdevs * sizeof(*lseg->oc.comps);
+
+	lseg = kzalloc(lseg_size, gfp_flags);
+	if (unlikely(!lseg)) {
 		dprintk("%s: Faild allocation numdevs=%d size=%zd\n", __func__,
-			numdevs, sizeof(*aolseg));
+			numdevs, lseg_size);
 		return -ENOMEM;
 	}
 
-	aolseg->olseg.oc.numdevs = numdevs;
-	aolseg->olseg.oc.single_comp = EC_MULTPLE_COMPS;
-	aolseg->olseg.oc.comps = aolseg->comps;
-	aolseg->olseg.oc.ods = aolseg->ods;
+	lseg->oc.numdevs = numdevs;
+	lseg->oc.single_comp = EC_MULTPLE_COMPS;
+	lseg->oc.ods = (void *)(lseg + 1);
+	lseg->oc.comps = (void *)(lseg->oc.ods + numdevs);
 
-	*pseg = &aolseg->olseg;
+	*pseg = lseg;
 	return 0;
 }
 
-- 
1.7.6.5

