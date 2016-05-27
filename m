Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:47320 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1752880AbcE0WcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 18:32:06 -0400
Date: 27 May 2016 17:25:38 -0400
Message-ID: <20160527212538.7693.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: bfields@fieldses.org, linux@sciencehorizons.net
Subject: Re: [PATCH RESEND 03/10] <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hash_string()
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
In-Reply-To: <20160527174019.GE25272@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I don't see yet what the problem is, but I can tell you that as of
> 95d5dfa805a6344e69ef41f56bb4955269079ec7 "fs/namei.c: Improve dcache
> hash function" my (Fedora 21 x86_64) VM no longer starts up reliably....

Just a note... the bug I explained in a previous e-mail was the
culprit, and it is now been confirmed fixed.

Here's the fixed patch, with extra comments around full_name_hash
for any future hackers.

(I also updated the self-test to prevent regressions.)


commit 0a3d46fc8bcc33f6157b3f4e72a075c4207cd673
Author: George Spelvin <linux@sciencehorizons.net>
Date:   Mon May 23 07:43:58 2016 -0400

    fs/namei.c: Improve dcache hash function
    
    Patch 0fed3ac866 improved the hash mixing, but the function is slower
    than necessary; there's a 7-instruction dependency chain (10 on x86)
    each loop iteration.
    
    Word-at-a-time access is a very tight loop (which is good, because
    link_path_walk() is one of the hottest code paths in the entire kernel),
    and the hash mixing function must not have a longer latency to avoid
    slowing it down.
    
    There do not appear to be any published fast hash functions that:
    1) Operate on the input a word at a time, and
    2) Don't need to know the length of the input beforehand, and
    3) Have a single iterated mixing function, not needing conditional
       branches or unrolling to distinguish different loop iterations.
    
    One of the algorithms which comes closest is Yann Collet's xxHash, but
    that's two dependent multiplies per word, which is too much.
    
    The key insights in this design are:
    
    1) Except for multiplies, to diffuse one input bit across 64 bits of hash
       state takes at least log2(64) = 6 sequentially dependent instructions.
       That is more cycles than we'd like.
    2) An operation like "hash ^= hash << 13" requires a second temporary
       register anyway, and on a 2-operand machine like x86, it's three
       instructions.
    3) A better use of a second register is to hold a two-word hash state.
       With careful design, no temporaries are needed at all, so it doesn't
       increase register pressure.  And this gets rid of register copying
       on 2-operand machines, so the code is smaller and faster.
    4) Using two words of state weakens the requriement for one-round mixing;
       we now have two rounds of mixing before cancellation is possible.
    5) A two-word hash state also allows operations on both halves to be
       done in parallel, so on a superscalar processor we get more mixing
       in fewer cycles.
    
    I ended up using a mixing function inspired by the ChaCha and Speck
    round functions.  It is 6 simple instructions and 3 cycles per iteration
    (assuming mutliply by 9 can be done by an "lea" isntruction):
    
    		x ^= *input++;
    	y ^= x;	x = ROL(x, K1);
    	x += y;	y = ROL(y, K2);
    	y *= 9;
    
    Not only is this reversible, two consecutive rounds are reversible:
    if you are given the initial and final states, but not the intermediate
    state, it is possible to compute both input words.  This means that at
    least 3 words of input are required to create a collision.
    
    (It also has the property, used by hash_name() to avoid a branch, that
    it hashes all-zero to all-zero.)
    
    The rotate constants K1 and K2 were found by experiment.  The search took
    a sample of random initial states (I used 1023) and considered the effect
    of flipping each of the 64 input bits on each of the 128 output bits two
    rounds later.  Each of the 8192 pairs can be considered a biased coin, and
    adding up the Shannon entropy of all of them produces a score.
    
    The best-scoring shifts also did well in other tests (flipping bits in y,
    trying 3 or 4 rounds of mixing, flipping all 64*63/2 pairs of input bits),
    so the choice was made with the additional constraint that the sum of the
    shifts is odd and not too close to the word size.
    
    The final state is then folded into a 32-bit hash value by a less carefully
    optimized multiply-based scheme.  This also has to be fast, as pathname
    components tend to be short (the most common case is one iteration!), but
    there's some room for latency, as there is a fair bit of intervening logic
    before the hash value is used for anything.
    
    (Performance verified with "bonnie++ -s 0 -n 1536:-2" on tmpfs.  I need
    a better benchmark; the numbers seem to show a slight dip in performance
    between 4.6.0 and this patch, but they're too noisy to quote.)
    
    Special thanks to Bruce fields for helping me find a nasty fencepost
    error in an earlier version of this patch.
    
    Signed-off-by: George Spelvin <linux@sciencehorizons.net>
    Thanks-to: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/namei.c b/fs/namei.c
index d43391d0..38e14ad0 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -35,6 +35,7 @@
 #include <linux/fs_struct.h>
 #include <linux/posix_acl.h>
 #include <linux/hash.h>
+#include <linux/bitops.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -1788,81 +1789,124 @@ static int walk_component(struct nameidata *nd, int flags)
 #include <asm/word-at-a-time.h>
 
 #ifdef CONFIG_64BIT
-
-static inline unsigned int fold_hash(unsigned long hash)
-{
-	return hash_64(hash, 32);
-}
+/*
+ * Register pressure in the mixing function is an issue, particularly
+ * on 32-bit x86, but almost any function requires one state value and
+ * one temporary.  Instead, use a function designed for two state values
+ * and no temporaries.
+ *
+ * This function cannot create a collision in only two iterations, so
+ * we have two iterations to achieve avalanche.  In those two iterations,
+ * we have six layers of mixing, which is enough to spread one bit's
+ * influence out to 2^6 = 64 state bits.
+ *
+ * Rotate constants are scored by considering either 64 one-bit input
+ * deltas or 64*63/2 = 2016 two-bit input deltas, and finding the
+ * probability of that delta causing a change to each of the 128 output
+ * bits, using a sample of random initial states.
+ *
+ * The Shannon entropy of the computed probabilities is then summed
+ * to produce a score.  Ideally, any input change has a 50% chance of
+ * toggling any given output bit.
+ *
+ * Mixing scores (in bits) for (12,45):
+ * Input delta: 1-bit      2-bit
+ * 1 round:     713.3    42542.6
+ * 2 rounds:   2753.7   140389.8
+ * 3 rounds:   5954.1   233458.2
+ * 4 rounds:   7862.6   256672.2
+ * Perfect:    8192     258048
+ *            (64*128) (64*63/2 * 128)
+ */
+#define HASH_MIX(x, y, a) 	\
+	( 	x ^= (a),	\
+	y ^= x,	x = rol64(x,12),\
+	x += y,	y = rol64(y,45),\
+	y *= 9			)
 
 /*
- * This is George Marsaglia's XORSHIFT generator.
- * It implements a maximum-period LFSR in only a few
- * instructions.  It also has the property (required
- * by hash_name()) that mix_hash(0) = 0.
+ * Fold two longs into one 32-bit hash value.  This must be fast, but
+ * latency isn't quite as critical, as there is a fair bit of additional
+ * work done before the hash value is used.
  */
-static inline unsigned long mix_hash(unsigned long hash)
+static inline unsigned int fold_hash(unsigned long x, unsigned long y)
 {
-	hash ^= hash << 13;
-	hash ^= hash >> 7;
-	hash ^= hash << 17;
-	return hash;
+        y ^= x * GOLDEN_RATIO_64;
+        y *= GOLDEN_RATIO_64;
+        return y >> 32;
 }
 
 #else	/* 32-bit case */
 
-#define fold_hash(x) (x)
+/*
+ * Mixing scores (in bits) for (7,20):
+ * Input delta: 1-bit      2-bit
+ * 1 round:     330.3     9201.6
+ * 2 rounds:   1246.4    25475.4
+ * 3 rounds:   1907.1    31295.1
+ * 4 rounds:   2042.3    31718.6
+ * Perfect:    2048      31744
+ *            (32*64)   (32*31/2 * 64)
+ */
+#define HASH_MIX(x, y, a)	\
+	( 	x ^= (a),	\
+	y ^= x,	x = rol32(x, 7),\
+	x += y,	y = rol32(y,20),\
+	y *= 9			)
 
-static inline unsigned long mix_hash(unsigned long hash)
+static inline unsigned int fold_hash(unsigned long x, unsigned long y)
 {
-	hash ^= hash << 13;
-	hash ^= hash >> 17;
-	hash ^= hash << 5;
-	return hash;
+	/* Use arch-optimized multiply if one exists */
+        return __hash_32(y ^ __hash_32(x));
 }
 
 #endif
 
-/* Return the hash of a string of known length */
+/*
+ * Return the hash of a string of known length.  This is carfully
+ * designed to match hash_name(), which is the more critical function.
+ * In particular, we must hash a final word containing 0..7 payload bytes,
+ * to match the way that hash_name() iterates until it finds the delimiter
+ * after the name.
+ */
 unsigned int full_name_hash(const char *name, unsigned int len)
 {
-	unsigned long a, hash = 0;
+	unsigned long a, x = 0, y = 0;
 
 	for (;;) {
 		a = load_unaligned_zeropad(name);
 		if (len < sizeof(unsigned long))
 			break;
-		hash = mix_hash(hash + a);
+		HASH_MIX(x, y, a);
 		name += sizeof(unsigned long);
 		len -= sizeof(unsigned long);
 		if (!len)
-			goto done;
+			goto done;	/* Optimize out bytemask_from_count(0) */
 	}
-	hash += a & bytemask_from_count(len);
+	x ^= a & bytemask_from_count(len);
 done:
-	return fold_hash(hash);
+	return fold_hash(x, y);
 }
 EXPORT_SYMBOL(full_name_hash);
 
 /* Return the "hash_len" (hash and length) of a null-terminated string */
 u64 hashlen_string(const char *name)
 {
-	unsigned long a, adata, mask, hash, len;
+	unsigned long a = 0, x = 0, y = 0, adata, mask, len;
 	const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;
 
-	hash = a = 0;
 	len = -sizeof(unsigned long);
 	do {
-		hash = mix_hash(hash + a);
+		HASH_MIX(x, y, a);
 		len += sizeof(unsigned long);
 		a = load_unaligned_zeropad(name+len);
 	} while (!has_zero(a, &adata, &constants));
 
 	adata = prep_zero_mask(a, adata, &constants);
 	mask = create_zero_mask(adata);
-	hash += a & zero_bytemask(mask);
-	len += find_zero(mask);
+	x ^= a & zero_bytemask(mask);
 
-	return hashlen_create(fold_hash(hash), len);
+	return hashlen_create(fold_hash(x, y), len + find_zero(mask));
 }
 EXPORT_SYMBOL(hashlen_string);
 
@@ -1872,13 +1916,12 @@ EXPORT_SYMBOL(hashlen_string);
  */
 static inline u64 hash_name(const char *name)
 {
-	unsigned long a, b, adata, bdata, mask, hash, len;
+	unsigned long a = 0, b, x = 0, y = 0, adata, bdata, mask, len;
 	const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;
 
-	hash = a = 0;
 	len = -sizeof(unsigned long);
 	do {
-		hash = mix_hash(hash + a);
+		HASH_MIX(x, y, a);
 		len += sizeof(unsigned long);
 		a = load_unaligned_zeropad(name+len);
 		b = a ^ REPEAT_BYTE('/');
@@ -1886,15 +1929,13 @@ static inline u64 hash_name(const char *name)
 
 	adata = prep_zero_mask(a, adata, &constants);
 	bdata = prep_zero_mask(b, bdata, &constants);
-
 	mask = create_zero_mask(adata | bdata);
+	x ^= a & zero_bytemask(mask);
 
-	hash += a & zero_bytemask(mask);
-	len += find_zero(mask);
-	return hashlen_create(fold_hash(hash), len);
+	return hashlen_create(fold_hash(x, y), len + find_zero(mask));
 }
 
-#else
+#else	/* !CONFIG_DCACHE_WORD_ACCESS: Slow, byte-at-a-time version */
 
 /* Return the hash of a string of known length */
 unsigned int full_name_hash(const char *name, unsigned int len)
