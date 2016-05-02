Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:41297 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753115AbcEBK33 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 06:29:29 -0400
Date: 2 May 2016 06:22:48 -0400
Message-ID: <20160502102248.18755.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de,
        torvalds@linux-foundation.org
Subject: [PATCH 2/2] <linux/hash.h>: Fix hash_64()'s horrible collision problem
Cc: bfields@fieldses.org, eric.dumazet@gmail.com, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, linux@horizon.com, riel@redhat.com
In-Reply-To: <20160502102016.17936.qmail@ns.horizon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hash_64() was using a low-bit-weight multiplier, which resulted in
very bad mixing of the high bits of the input.  In particular,
page-aligned pointers (low 12 bits not used) were a disaster,

Since all 64-bit processors (I checked back to the MIPS R4000 and
Alpha 21064) have hardware multipliers and don't benefit from this
"optimization", use the proper golden ratio value.

Avoid performance problems on 32-bit machines by providing a totally
separate implementation for them based on 32-bit arithmetic.

Keep the bad multiplier for hash_32() for now, at Linus' request.
"Sparse in 32 bits" is not quite as bad as "sparse in 64 bits".

Explicitly document that the algorithm is not stable.  I've tried to
check all callers for inadvertent dependence on the exact numerical value,
but some them are so confusing (*cough* Lustre *cough*) that I can't
tell for sure.

Reported-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: George Spelvin <linux@horizon.com>
---
 include/linux/hash.h | 151 ++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 107 insertions(+), 44 deletions(-)

diff --git a/include/linux/hash.h b/include/linux/hash.h
index 05003fdc..64c44e20 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -1,63 +1,56 @@
 #ifndef _LINUX_HASH_H
 #define _LINUX_HASH_H
-/* Fast hashing routine for ints,  longs and pointers.
-   (C) 2002 Nadia Yvette Chambers, IBM */
-
 /*
- * Knuth recommends primes in approximately golden ratio to the maximum
- * integer representable by a machine word for multiplicative hashing.
+ * Fast hashing routine for ints, longs and pointers.
+ * (C) 2002 Nadia Yvette Chambers, IBM
+ *
+ * These are used for small in-memory hash tables, where speed is a
+ * primary concern.  If you want something a little bit stronger, see
+ * <linux/jhash.h>, especially functions like jhash_3words().  If your
+ * hash table is subject to a hash collision denial of service attack,
+ * use something cryptographic.
+ *
+ * Note that the algorithms used are not guaranteed stable across kernel
+ * versions or architectures!  In particular, hash_64() is implemented
+ * differently on 32- and 64-bit machines.  Do not let external behavior
+ * depend on the hash values.
+ *
+ * The algorithm used is straight from Knuth: multiply a w-bit word by
+ * a suitable large constant, and take the high bits of the w-bit result.
+ *
  * Chuck Lever verified the effectiveness of this technique:
  * http://www.citi.umich.edu/techreports/reports/citi-tr-00-1.pdf
  *
- * These primes are chosen to be bit-sparse, that is operations on
- * them can use shifts and additions instead of multiplications for
- * machines where multiplications are slow.
+ * A good reference is Mikkel Thorup, "High Speed Hashing for
+ * Integers and Strings" at http://arxiv.org/abs/1504.06804 and
+ * https://www.youtube.com/watch?v=cB85UZKJQTc
+ *
+ * Because the current algorithm is linear (hash(a+b) = hash(a) + hash(b)),
+ * adding or subtracting hash values is just as likely to cause collisions
+ * as adding or subtracting the keys themselves.
  */
-
 #include <asm/types.h>
 #include <linux/compiler.h>
 
-/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
-#define GOLDEN_RATIO_PRIME_32 0x9e370001UL
-/*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
-#define GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001UL
+/*
+ * Although a random odd number will do, it turns out that the golden ratio
+ * phi = (sqrt(5)-1)/2, or its negative, has particularly nice properties.
+ *
+ * These are actually the negative, (1 - phi) = (phi^2) = (3 - sqrt(5))/2.
+ * (See Knuth vol 3, section 6.4, exercise 9.)
+ */
+#define GOLDEN_RATIO_32 0x61C88647
+#define GOLDEN_RATIO_64 0x61C8864680B583EBull
 
-#if BITS_PER_LONG == 32
-#define GOLDEN_RATIO_PRIME GOLDEN_RATIO_PRIME_32
-#define __hash_long(val) __hash_32(val)
-#define hash_long(val, bits) hash_32(val, bits)
-#elif BITS_PER_LONG == 64
+#if BITS_PER_LONG == 64
+
+#define GOLDEN_RATIO_PRIME GOLDEN_RATIO_64	/* Used in fs/inode.c */
 #define __hash_long(val) __hash_64(val)
 #define hash_long(val, bits) hash_64(val, bits)
-#define GOLDEN_RATIO_PRIME GOLDEN_RATIO_PRIME_64
-#else
-#error Wordsize not 32 or 64
-#endif
 
 static __always_inline u64 __hash_64(u64 val)
 {
-	u64 hash = val;
-
-#if defined(CONFIG_ARCH_HAS_FAST_MULTIPLIER) && BITS_PER_LONG == 64
-	hash = hash * GOLDEN_RATIO_PRIME_64;
-#else
-	/*  Sigh, gcc can't optimise this alone like it does for 32 bits. */
-	u64 n = hash;
-	n <<= 18;
-	hash -= n;
-	n <<= 33;
-	hash -= n;
-	n <<= 3;
-	hash += n;
-	n <<= 3;
-	hash -= n;
-	n <<= 4;
-	hash += n;
-	n <<= 2;
-	hash += n;
-#endif
-
-	return hash;
+	return val * GOLDEN_RATIO_64;
 }
 
 static __always_inline u64 hash_64(u64 val, unsigned bits)
@@ -66,6 +59,75 @@ static __always_inline u64 hash_64(u64 val, unsigned bits)
 	return __hash_64(val) >> (64 - bits);
 }
 
+#elif BITS_PER_LONG == 32
+
+#define GOLDEN_RATIO_PRIME GOLDEN_RATIO_32
+#define __hash_long(val) __hash_32(val)
+#define hash_long(val, bits) hash_32(val, bits)
+
+/*
+ * Because 64-bit multiplications are very expensive on 32-bit machines,
+ * provide a completely separate implementation for them.
+ *
+ * This is mostly used via the hash_long() and hash_ptr() wrappers,
+ * which use hash_32() on 32-bit platforms, but there are some direct
+ * users of hash_64() in 32-bit kernels.
+ *
+ * Note that there is no __hash_64 function at all; that exists
+ * only to implement __hash_long().
+ *
+ * The algorithm is somewhat ad-hoc, but achieves decent mixing.
+ */
+static __always_inline u32 hash_64(u64 val, unsigned bits)
+{
+	u32 hash = (uint32)(val >> 32) * GOLDEN_RATIO_32;
+	hash += (uint32)val;
+	hash *= GOLDEN_RATIO_32;
+	return hash >> (32 - bits);
+}
+
+#else /* BITS_PER_LONG is something else */
+#error Wordsize not 32 or 64
+#endif
+
+
+/*
+ * This is the old bastard constant: a low-bit-weight
+ * prime close to 2^32 * phi = 0x9E3779B9.
+ *
+ * The purpose of the low bit weight is to make the shift-and-add
+ * code faster on processors like ARMv2 without hardware multiply.
+ * The downside is that the high bits of the input are hashed very weakly.
+ * In particular, the high 16 bits of input are just shifted up and added,
+ * so if you ask for b < 16 bits of output, bits 16..31-b of the input
+ * barely affect the output.
+ *
+ * Annoyingly, GCC compiles this into 6 shifts and adds, which
+ * is enough to multiply by the full GOLDEN_RATIO_32 using a
+ * cleverer algorithm:
+ *
+ * unsigned hash_32(unsigned x)
+ * {
+ * 	unsigned y, z;
+ *
+ * 	y = (x << 19) + x;
+ * 	z = (x << 9) + y;
+ * 	x = (x << 23) + z;
+ * 	z = (z << 8) + y;
+ * 	x = (x << 6) - x;
+ * 	return (z << 3) + x;
+ * }
+ *
+ * (Found by Yevgen Voronenko's Hcub algorithm, from
+ * http://spiral.ece.cmu.edu/mcm/gen.html)
+ *
+ * Unfortunately, figuring out which version to compile requires
+ * replicating the compiler's logic in Kconfig or the preprocessor.
+ */
+
+/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
+#define GOLDEN_RATIO_PRIME_32 0x9e370001UL
+
 static inline u32 __hash_32(u32 val)
 {
 	/* On some cpus multiply is faster, on others gcc will do shifts */
@@ -83,6 +145,7 @@ static inline u32 hash_ptr(const void *ptr, unsigned bits)
 	return hash_long((unsigned long)ptr, bits);
 }
 
+/* This really should be called "fold32_ptr"; it barely hashes at all. */
 static inline u32 hash32_ptr(const void *ptr)
 {
 	unsigned long val = (unsigned long)ptr;
-- 
2.8.1

