Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495145;
	b=NWC6UKsdL2EqojK52Qn8oFFfPNVk7xeK5Xje1lc2WEHrNYpwbrGq/1ShGqPYBovarn/Y
	 2j2qdSqhr8y1drnOfThdoIiMRqQ1upcvTMBJRCfXrm4x/NYdjz0NkBPGboVOJs2gvEgGr
	 mwtK2U/F13HheOFmbxGnQ0LYhef8Yi+jaaPkm6Sucz6of1wFqb0RCukDeCV+G8u+zSuET
	 XKHhJI798We6HboV+qLBJG22Oxn0XfWdZpeJ3YZkwnZBTZVCVcLbHySs0lNNBXxn8FtJt
	 dthO2JCoc/IdienHkyxu7Kx7blv9KTsX78SQ0XLUK0xJejsfFxUvHqmd3VhiVQYlSaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495145;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XrCuojfslRwBhFGohWFhiBZyv5JuyJGQO7/4S3I2J3w=;
	b=0KPhtEKWOxloJrLNC0dr75ZfaCUt2Z24MYRoZ/NcPDaef7D9FvhOu65XHjgo8/zdxm4C
	 gLG70qdkKgL0cCJfStK7dJ9TpKYPe/bNNenT2N4RPP0kojbOb4t9GGF64WBTbwgLuKxvX
	 bsV97eJLHmCXBvOz9ddFHvlEn6umkOaw/JJTjdftxdAqKW3AjkL/gg3jaN24w8u3mlFv2
	 QFEFmIO1Z5IEqQq4l3rS/jJ+SdnEOZZQ/NrCyacec/5GDE/A7J5NaXMYCnCGpbaNIdTs+
	 Te8iz2sbwJgf5HcN0RRS5eC88N3a9Q24Py/4jTLKtqZvKH3LhDeSSGNARS/l/pTX2SA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H3ByJqm6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01530606A31C;
	Thu, 12 Nov 2026 14:52:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H3ByJqm6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC2291F00A08;
	Thu, 12 Nov 2026 14:52:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495144;
	bh=XrCuojfslRwBhFGohWFhiBZyv5JuyJGQO7/4S3I2J3w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=H3ByJqm6akQfGCYm1LDLHkSTGq+HRRvKSxEWOd0Q5FdzAMtiYn+hDWbDW+wqTjNtQ
	 t8t2TP8F6EGWpDR2wMyvu/gajKIKQQaezHXK/YPbMcjk4MR0OO90CWnVCktVKrQiTP
	 1+Y89vKfveija41KYIPl2lkGFpFmYg5ZNuiMyGOXoy/UHvNxVB9hK9ZMce9pdqIcgZ
	 S6wazBH7001rM5+x6DLEepdWquz+TuMgVZ+61y2HfmjVM2IxDLvcxmOqBtX0/tFuMa
	 OMlbgY04IsyYJ++F4bcAKsUlUxb+FyLCTZBwSI4knLpfqOCWXnPFRCjOEPAs3ZNFE0
	 /YkkMNIhqt+wg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:06 -0500
Subject: [PATCH net-next v2 02/10] lib: Add a "stringset" data structure
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261112-tls-session-tags-v2-2-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=23922; i=cel@kernel.org;
 h=from:subject:message-id; bh=FMLtj7sx4FMt82A6GdwJA7wxibBIYJQTQpI5Or9ddQ8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgqRTB+0DyV0WL29nwIN9pSORfJIfsg1Wyn
 q4cpGcVHGqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l8OpD/4oebCaO9t3zKVo6WIyXZHP++fCChqXhi2qKoXpZjhdEmbreLfypSReXvK04PXz5yOHqrc
 ulhDNG9oWTF+gejBQqq00ksOmVFb4Gbn57GRYe7+Jy1Ze+KY/yycgYjaDWsulzpMapIhg/+x1m7
 E8BjUaLwRiNLp65+faESH4ElKGm1ZE2H8lQ0mSanTEMTv78FVEv9Qn58RTDekWuLDZHHFhMYKA4
 TJHeBC7Vh6J6AyvVw8qPyDC2vHmUciD6xRtaKQn8PUyTv8M3Q22pDyifcXMbfM2eyW/JtPKA1y5
 8qiJnbjukK4IzYovd+Qed0HMFOMagHCiIfZySpDNme79ZS4HjMPdPDzRSD2r3FkhJgr2c/ah8Qd
 XJbOKXcdzv+qAxI+Hi40puV280IVeE/mu+TxUxbUFDNS5MIA3RB1/Fde/Mde6lDWzoLaZfn/UzC
 nNp0Zirsgcc/Jx96MfNeWjvnJHMkty7c39WqTyDUjXyDTgaTgKwMoMTXhjWW1ZXn/GUnoXROgxB
 RtRi+6E3mwHqvAMwRRRo3WU6fcrsFdoPY8d+lj6W2z/FdSyCQ5I+n+redPq5JLPfOInSQUBwhkg
 BE33raCVNHiEuWUgjC3LWE9GwTG54HFjDRg6dkMqxEJqcBy5DhOABiZeok8lizCvKdP4kqwyF11
 c9LUhTRkREEasUg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Access control mechanisms sometimes need to match metadata tags
between a session and a resource. A stringset provides efficient
membership testing and set intersection operations for this purpose.

Set intersection, not membership, is what motivates a purpose-built
structure. xarray and rbtree answer a membership query in O(log M),
so intersecting by probing costs O(N log M). rhashtable probes in
O(1) expected, but pays a hash per element and gives up the ordering
a merge relies on. Two sorted arrays instead merge in a single
O(N + M) pass.

The implementation therefore uses a sorted array of string pointers.
Beyond the intersection cost, a sorted array needs no per-element
node allocation. An rbtree does, so it carries more memory overhead
for the small sets typical of resource tagging.

The API follows a build-then-query pattern: callers initialize,
allocate capacity, add strings, then finalize before querying. Once
finalized, the stringset is suitable for concurrent read access.

Build the library only when a consumer selects CONFIG_STRINGSET.
Consumers of the new APIs arrive in subsequent patches.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/core-api/index.rst     |   1 +
 Documentation/core-api/stringset.rst | 243 +++++++++++++++++++++++++++++++++++
 MAINTAINERS                          |   7 +
 include/linux/stringset.h            | 191 +++++++++++++++++++++++++++
 lib/Kconfig                          |  12 ++
 lib/Makefile                         |   1 +
 lib/stringset.c                      | 190 +++++++++++++++++++++++++++
 7 files changed, 645 insertions(+)

diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index 92f91c6a0d79..929bf11828c3 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -45,6 +45,7 @@ Library functionality that is used throughout the kernel.
    idr
    circular-buffers
    rbtree
+   stringset
    generic-radix-tree
    packing
    this_cpu_ops
diff --git a/Documentation/core-api/stringset.rst b/Documentation/core-api/stringset.rst
new file mode 100644
index 000000000000..549199ae1fa2
--- /dev/null
+++ b/Documentation/core-api/stringset.rst
@@ -0,0 +1,243 @@
+.. SPDX-License-Identifier: GPL-2.0+
+
+=========
+Stringset
+=========
+
+Overview
+========
+
+A stringset is a set of strings, intended for resource tagging where
+metadata about a resource is represented simply by a name. The public
+API can be found in ``<linux/stringset.h>``.
+
+
+Initialization and Destruction
+==============================
+
+A stringset must be initialized before use::
+
+    struct stringset set;
+    stringset_init(&set);
+
+``DEFINE_STRINGSET()`` declares a stringset and initializes it in
+one step::
+
+    DEFINE_STRINGSET(set);
+
+Before adding strings, allocate capacity::
+
+    if (!stringset_alloc(&set, num_strings, GFP_KERNEL))
+        return -ENOMEM;
+
+When finished, release all resources::
+
+    stringset_destroy(&set);
+
+This frees all strings and the array. The stringset is reinitialized
+and may be reused by calling ``stringset_alloc()`` again.
+
+
+Adding Strings
+==============
+
+Two functions are provided for adding strings. Both require that
+sufficient capacity has been allocated via ``stringset_alloc()``.
+
+``stringset_add()``
+    Adds a string that is already in kmalloc'd memory. On success,
+    the stringset takes ownership of the string and frees it when
+    the stringset is destroyed, or at ``stringset_finalize()`` if it
+    is a duplicate::
+
+        char *str = kstrdup("example", GFP_KERNEL);
+        if (!str || !stringset_add(&set, str))
+            kfree(str);  /* failed, caller must free */
+
+``stringset_add_dup()``
+    Duplicates the string internally. The caller retains ownership
+    of the original string::
+
+        if (!stringset_add_dup(&set, "example", GFP_KERNEL))
+            return -ENOMEM;
+
+Both functions return true on success, false on failure. Strings must
+not be added after ``stringset_finalize()`` has been called. Pass
+``GFP_ATOMIC`` to ``stringset_add_dup()`` in atomic context.
+
+
+Finalizing
+==========
+
+After adding all strings, the stringset must be finalized before
+querying::
+
+    stringset_finalize(&set);
+
+This sorts the array to enable efficient binary search and removes
+any duplicate strings. Calling ``stringset_is_member()`` or
+``stringset_intersection()`` on a non-finalized stringset warns and
+returns ``false``.
+
+
+Querying Strings
+================
+
+``stringset_is_empty()``
+    Returns true if the stringset contains no strings.
+
+``stringset_count()``
+    Returns the number of strings in the stringset. Before finalization,
+    this is the number of strings added; after finalization, this is
+    the number of unique strings.
+
+``stringset_is_member()``
+    Returns true if a string is present in the stringset. Uses binary
+    search for O(log N) complexity::
+
+        if (stringset_is_member(&set, "example"))
+            pr_info("string found\n");
+
+``stringset_intersection()``
+    Returns true if two stringsets share at least one common string.
+    Uses merge-style comparison for O(N+M) complexity::
+
+        if (stringset_intersection(&set1, &set2))
+            pr_info("sets overlap\n");
+
+
+Iteration
+=========
+
+Use ``stringset_for_each()`` to iterate over all strings::
+
+    unsigned int index;
+    char *str;
+
+    stringset_for_each(&set, index, str)
+        pr_info("string: %s\n", str);
+
+Callers should not depend on the order in which strings are returned.
+Modifying the stringset during iteration produces undefined behavior.
+
+
+Copying
+=======
+
+``stringset_copy()`` duplicates all strings from one stringset to
+another::
+
+    struct stringset copy;
+
+    stringset_init(&copy);
+    if (!stringset_copy(&copy, &original, GFP_KERNEL))
+        pr_err("copy failed\n");
+
+The source stringset must be finalized before copying; copying an
+unfinalized stringset warns and returns failure. The destination
+stringset is initialized and ready for queries after this function
+returns (no separate ``stringset_finalize()`` call is needed). Each
+string is duplicated, so the two stringsets are fully independent after
+copying.
+
+
+Typical Usage Pattern
+=====================
+
+A typical usage pattern for building a stringset::
+
+    struct stringset set;
+
+    stringset_init(&set);
+    if (!stringset_alloc(&set, count, GFP_KERNEL))
+        return -ENOMEM;
+
+    for (i = 0; i < count; i++) {
+        if (!stringset_add_dup(&set, strings[i], GFP_KERNEL)) {
+            stringset_destroy(&set);
+            return -ENOMEM;
+        }
+    }
+    stringset_finalize(&set);
+
+    /* Now safe to query */
+    if (stringset_is_member(&set, "target"))
+        do_something();
+
+    stringset_destroy(&set);
+
+
+Thread Safety
+=============
+
+Stringsets have no internal locking. Callers provide synchronization
+between writers and readers.
+
+The build-and-finalize phase mutates the stringset; the post-finalize
+query phase reads from it. The two phases must be separated by a
+publication boundary, because ``stringset_finalize()`` itself carries
+no memory barrier. A reader that observes the finalized stringset
+before the writer's stores have propagated may see a stale
+``ss_count`` or a partially populated ``ss_strings[]`` array.
+
+Three publication patterns are sufficient:
+
+* Lock release after ``stringset_finalize()``, lock acquire before
+  each query. The matching unlock/lock pair supplies release and
+  acquire ordering.
+
+* ``rcu_assign_pointer()`` of the stringset pointer after
+  ``stringset_finalize()``, paired with ``rcu_dereference()`` inside
+  an RCU read-side critical section on the reader.
+
+* ``smp_store_release()`` of the stringset pointer after
+  ``stringset_finalize()``, paired with ``smp_load_acquire()`` on the
+  reader.
+
+Once published, the stringset must remain immutable until no further
+readers can observe it. ``stringset_destroy()`` is not safe against
+concurrent readers, and ``stringset_finalize()`` must not be called
+more than once. With RCU publication, callers typically defer
+destruction to a grace period (``synchronize_rcu()`` before
+``stringset_destroy()``, or ``stringset_destroy()`` from a
+``call_rcu()`` callback) so that in-flight readers drain before
+the storage is freed.
+
+
+Implementation
+==============
+
+Each stringset is rooted on the following structure::
+
+    struct stringset {
+            char         **ss_strings;
+            unsigned int   ss_count;
+            unsigned int   ss_capacity;
+            bool           ss_finalized;
+    };
+
+The implementation uses a sorted array of string pointers, providing
+O(log N) membership testing and O(N+M) intersection operations.
+
++----------------------------+-------------+
+| Operation                  | Complexity  |
++============================+=============+
+| stringset_add              | O(1)        |
++----------------------------+-------------+
+| stringset_finalize         | O(N log N)  |
++----------------------------+-------------+
+| stringset_is_member        | O(log N)    |
++----------------------------+-------------+
+| stringset_intersection     | O(N + M)    |
++----------------------------+-------------+
+| stringset_copy             | O(N)        |
++----------------------------+-------------+
+
+API Reference
+=============
+
+.. kernel-doc:: include/linux/stringset.h
+   :internal:
+
+.. kernel-doc:: lib/stringset.c
+   :export:
diff --git a/MAINTAINERS b/MAINTAINERS
index 893b0670a7b6..b977559f24f6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -27013,6 +27013,13 @@ S:	Maintained
 F:	Documentation/networking/device_drivers/ethernet/stmicro/
 F:	drivers/net/ethernet/stmicro/stmmac/
 
+STRINGSET DATA STRUCTURE
+M:	Chuck Lever <cel@kernel.org>
+S:	Maintained
+F:	Documentation/core-api/stringset.rst
+F:	include/linux/stringset.h
+F:	lib/stringset.c
+
 SUN HAPPY MEAL ETHERNET DRIVER
 M:	Sean Anderson <seanga2@gmail.com>
 S:	Maintained
diff --git a/include/linux/stringset.h b/include/linux/stringset.h
new file mode 100644
index 000000000000..fd41ea23f2b1
--- /dev/null
+++ b/include/linux/stringset.h
@@ -0,0 +1,191 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Stringsets
+ *
+ * Copyright (c) 2025, Oracle and/or its affiliates.
+ * Author: Chuck Lever <chuck.lever@oracle.com>
+ *
+ * A stringset is a set of strings. See
+ * Documentation/core-api/stringset.rst for how to use stringsets.
+ *
+ * Stringsets have no internal locking. Callers synchronize writers
+ * against readers, publish the finalized set with release/acquire
+ * ordering, and drain readers before stringset_destroy(). See the
+ * Thread Safety section of Documentation/core-api/stringset.rst.
+ */
+
+#ifndef _LINUX_STRINGSET_H
+#define _LINUX_STRINGSET_H
+
+#include <linux/bug.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+struct stringset {
+	char		**ss_strings;
+	unsigned int	ss_count;
+	unsigned int	ss_capacity;
+	bool		ss_finalized;
+};
+
+#define STRINGSET_INIT \
+	{ .ss_strings = NULL, .ss_count = 0, .ss_capacity = 0, .ss_finalized = false }
+#define DEFINE_STRINGSET(name) \
+	struct stringset name = STRINGSET_INIT
+
+/**
+ * stringset_for_each - Iterate over items in a stringset
+ * @set: An initialized stringset containing zero or more items
+ * @index: Index counter for the iteration
+ * @str: String retrieved from the stringset
+ */
+#define stringset_for_each(set, index, str) \
+	for ((index) = 0; (index) < (set)->ss_count && \
+	     ((str) = (set)->ss_strings[index], true); (index)++)
+
+/**
+ * stringset_init - Initialize an empty stringset
+ * @set: stringset to be initialized
+ */
+static inline void stringset_init(struct stringset *set)
+{
+	set->ss_strings = NULL;
+	set->ss_count = 0;
+	set->ss_capacity = 0;
+	set->ss_finalized = false;
+}
+
+/**
+ * stringset_alloc - Pre-allocate space for strings
+ * @set: An initialized stringset
+ * @capacity: Number of strings to allocate space for
+ * @gfp: Memory allocation flags
+ *
+ * This function allocates only once per stringset. Calling it on a
+ * stringset that is already allocated returns failure. stringset_destroy()
+ * releases the allocation, after which the stringset may be allocated
+ * again.
+ *
+ * @capacity may be zero. The stringset then represents an empty set, and
+ * stringset_add() rejects further additions. The same state is produced
+ * by DEFINE_STRINGSET() and stringset_init() alone, so callers that know
+ * the set is empty may skip stringset_alloc() entirely. An empty set
+ * still goes through stringset_finalize() before stringset_is_member()
+ * or stringset_intersection() can query it. A zero-capacity call allocates
+ * nothing, so a later stringset_alloc() on the same set still succeeds.
+ *
+ * Return:
+ *   %true: allocation succeeded (or @capacity was zero)
+ *   %false: allocation failed or stringset already allocated
+ */
+static inline __must_check bool
+stringset_alloc(struct stringset *set, unsigned int capacity, gfp_t gfp)
+{
+	if (set->ss_strings)
+		return false;
+	if (capacity == 0)
+		return true;
+
+	set->ss_strings = kcalloc(capacity, sizeof(char *), gfp);
+	if (!set->ss_strings)
+		return false;
+	set->ss_capacity = capacity;
+	return true;
+}
+
+/**
+ * stringset_is_empty - Determine if a stringset contains any strings
+ * @set: An initialized stringset to be checked
+ *
+ * Return:
+ *    %true: if @set is empty
+ *    %false: if @set contains one or more strings
+ */
+static inline bool stringset_is_empty(const struct stringset *set)
+{
+	return set->ss_count == 0;
+}
+
+/**
+ * stringset_count - Return the number of strings in a stringset
+ * @set: An initialized stringset to be checked
+ *
+ * If called before stringset_finalize(), returns the number of strings
+ * added. If called after, returns the number of unique strings.
+ *
+ * Return:
+ *    The number of strings in @set
+ */
+static inline unsigned int stringset_count(const struct stringset *set)
+{
+	return set->ss_count;
+}
+
+/**
+ * stringset_add - Add a string to a stringset
+ * @set: An initialized stringset with available capacity
+ * @str: non-NULL string to be added to @set, in kmalloc'd memory
+ *
+ * On success, @str is now owned by @set and will be freed either
+ * by stringset_finalize() (if a content duplicate) or stringset_destroy().
+ * The stringset must have been allocated with sufficient capacity via
+ * stringset_alloc(). Strings must not be added after stringset_finalize()
+ * has been called. Callers must not hand the same pointer to stringset_add()
+ * more than once: ownership has already transferred, and a second add
+ * produces a double-free at stringset_destroy().
+ *
+ * Return:
+ *   %true: @str is now a member of @set
+ *   %false: @str could not be added (NULL, no capacity, or @set is
+ *           already finalized)
+ */
+static inline __must_check bool
+stringset_add(struct stringset *set, char *str)
+{
+	if (WARN_ON_ONCE(set->ss_finalized))
+		return false;
+	if (!str || set->ss_count >= set->ss_capacity)
+		return false;
+	set->ss_strings[set->ss_count++] = str;
+	return true;
+}
+
+/**
+ * stringset_add_dup - Add a copy of a string to a stringset
+ * @set: An initialized stringset with available capacity
+ * @str: non-NULL string to be copied and added to @set
+ * @gfp: Memory allocation flags
+ *
+ * On success, @str will have been copied into a kmalloc'd
+ * buffer. The caller can release @str immediately. Strings must not
+ * be added after stringset_finalize() has been called.
+ *
+ * Return:
+ *   %true: @str is now a member of @set
+ *   %false: @str could not be added (NULL, no capacity, ENOMEM, or
+ *           @set is already finalized)
+ */
+static inline __must_check bool
+stringset_add_dup(struct stringset *set, const char *str, gfp_t gfp)
+{
+	char *entry;
+
+	if (WARN_ON_ONCE(set->ss_finalized))
+		return false;
+	if (!str || set->ss_count >= set->ss_capacity)
+		return false;
+	entry = kstrdup(str, gfp);
+	if (!entry)
+		return false;
+	set->ss_strings[set->ss_count++] = entry;
+	return true;
+}
+
+/* Implemented in lib/stringset.c */
+void stringset_finalize(struct stringset *set);
+void stringset_destroy(struct stringset *set);
+bool stringset_is_member(const struct stringset *set, const char *str);
+bool stringset_copy(struct stringset *dest, const struct stringset *src, gfp_t gfp);
+bool stringset_intersection(const struct stringset *set1, const struct stringset *set2);
+
+#endif /* _LINUX_STRINGSET_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 1e42f5167c68..c8ba3f7e13d8 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -363,6 +363,18 @@ config ASSOCIATIVE_ARRAY
 
 	  for more information.
 
+config STRINGSET
+	bool
+	help
+	  A sorted set of strings, built once and then queried for
+	  membership and intersection.
+
+	  See:
+
+		Documentation/core-api/stringset.rst
+
+	  for more information.
+
 config CLOSURES
 	bool
 
diff --git a/lib/Makefile b/lib/Makefile
index a2afe954805c..cbed3e2e7cd3 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -61,6 +61,7 @@ obj-y += bcd.o sort.o parser.o debug_locks.o random32.o \
 	 generic-radix-tree.o bitmap-str.o
 obj-y += string_helpers.o
 obj-y += hexdump.o
+obj-$(CONFIG_STRINGSET) += stringset.o
 obj-$(CONFIG_TEST_HEXDUMP) += test_hexdump.o
 obj-y += kstrtox.o
 obj-$(CONFIG_FIND_BIT_BENCHMARK) += find_bit_benchmark.o
diff --git a/lib/stringset.c b/lib/stringset.c
new file mode 100644
index 000000000000..2f77b048ffc5
--- /dev/null
+++ b/lib/stringset.c
@@ -0,0 +1,190 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Stringsets - a sorted set of strings
+ *
+ * Copyright (c) 2025, Oracle and/or its affiliates.
+ * Author: Chuck Lever <chuck.lever@oracle.com>
+ */
+
+#include <linux/bug.h>
+#include <linux/export.h>
+#include <linux/sort.h>
+#include <linux/string.h>
+#include <linux/stringset.h>
+
+static int stringset_cmp(const void *a, const void *b)
+{
+	const char * const *sa = a;
+	const char * const *sb = b;
+
+	return strcmp(*sa, *sb);
+}
+
+/**
+ * stringset_finalize - Sort the stringset and remove duplicates
+ * @set: An initialized stringset that has been populated
+ *
+ * This must be called after all strings have been added and before
+ * calling stringset_is_member(), stringset_intersection(), or
+ * stringset_copy(). Duplicate strings are removed and their memory
+ * is freed.
+ */
+void stringset_finalize(struct stringset *set)
+{
+	unsigned int i, j;
+
+	if (WARN_ON_ONCE(set->ss_finalized))
+		return;
+	if (set->ss_count > 1) {
+		sort(set->ss_strings, set->ss_count, sizeof(char *),
+		     stringset_cmp, NULL);
+
+		for (i = 0, j = 1; j < set->ss_count; j++) {
+			if (strcmp(set->ss_strings[i], set->ss_strings[j]) == 0)
+				kfree(set->ss_strings[j]);
+			else
+				set->ss_strings[++i] = set->ss_strings[j];
+		}
+		set->ss_count = i + 1;
+	}
+	set->ss_finalized = true;
+}
+EXPORT_SYMBOL_GPL(stringset_finalize);
+
+/**
+ * stringset_destroy - Release stringset resources
+ * @set: stringset to be destroyed
+ */
+void stringset_destroy(struct stringset *set)
+{
+	unsigned int i;
+
+	for (i = 0; i < set->ss_count; i++)
+		kfree(set->ss_strings[i]);
+	kfree(set->ss_strings);
+	stringset_init(set);
+}
+EXPORT_SYMBOL_GPL(stringset_destroy);
+
+/**
+ * stringset_is_member - Check if a string is already a member of a stringset
+ * @set: An initialized and finalized stringset to be checked
+ * @str: string to search for
+ *
+ * Uses binary search. The stringset must have been finalized first;
+ * a query on an unfinalized stringset warns and returns %false.
+ *
+ * Return:
+ *   %true: if @str is a member of @set
+ *   %false: if @str is not a member of @set, or @set is not finalized
+ */
+bool stringset_is_member(const struct stringset *set, const char *str)
+{
+	unsigned int low = 0, high = set->ss_count;
+
+	if (WARN_ON_ONCE(!set->ss_finalized))
+		return false;
+	/*
+	 * Open-coded rather than bsearch() to call strcmp() directly,
+	 * avoiding an indirect comparator call per search step.
+	 */
+	while (low < high) {
+		unsigned int mid = low + (high - low) / 2;
+		int cmp = strcmp(str, set->ss_strings[mid]);
+
+		if (cmp == 0)
+			return true;
+		if (cmp < 0)
+			high = mid;
+		else
+			low = mid + 1;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(stringset_is_member);
+
+/**
+ * stringset_copy - Duplicate strings to another stringset
+ * @dest: An unallocated, initialized stringset to be filled
+ * @src: An initialized, finalized stringset to be copied from
+ * @gfp: Memory allocation flags
+ *
+ * @dest must be initialized -- via STRINGSET_INIT, DEFINE_STRINGSET,
+ * stringset_init(), or a prior stringset_destroy() -- and must not yet
+ * have storage allocated. An already-allocated @dest is a caller error:
+ * the copy warns, frees @dest's storage, and returns failure.
+ *
+ * @src must be finalized: a copy reproduces @src's sorted, queryable
+ * state, so copying an unfinalized stringset warns and returns failure.
+ *
+ * On success @dest is populated and ready for use; no call to
+ * stringset_finalize() is required. On failure @dest is left as an
+ * empty, finalized stringset, so callers can safely run queries
+ * against it without first checking the return value.
+ *
+ * Return:
+ *   %true: All strings in @src were copied to @dest
+ *   %false: A failure occurred; @dest is empty and finalized
+ */
+bool stringset_copy(struct stringset *dest, const struct stringset *src, gfp_t gfp)
+{
+	unsigned int i;
+
+	if (WARN_ON_ONCE(dest->ss_strings))
+		goto out_fail;
+	if (WARN_ON_ONCE(!src->ss_finalized))
+		goto out_fail;
+	if (src->ss_count && !stringset_alloc(dest, src->ss_count, gfp))
+		goto out_fail;
+	for (i = 0; i < src->ss_count; i++) {
+		char *entry = kstrdup(src->ss_strings[i], gfp);
+
+		if (!entry)
+			goto out_fail;
+		dest->ss_strings[dest->ss_count++] = entry;
+	}
+	/* src is finalized and thus sorted, so dest is too */
+	dest->ss_finalized = true;
+	return true;
+
+out_fail:
+	stringset_destroy(dest);
+	dest->ss_finalized = true;
+	return false;
+}
+EXPORT_SYMBOL_GPL(stringset_copy);
+
+/**
+ * stringset_intersection - Report if there are common strings
+ * @set1: An initialized and finalized stringset
+ * @set2: Another initialized and finalized stringset
+ *
+ * Uses merge-style comparison of two sorted arrays for O(N+M)
+ * complexity. Both stringsets must have been finalized first; a
+ * query on an unfinalized stringset warns and returns %false.
+ *
+ * Return:
+ *   %true: @set1 and @set2 have at least one common string
+ *   %false: @set1 and @set2 have no strings in common, or either
+ *           stringset is not finalized
+ */
+bool stringset_intersection(const struct stringset *set1, const struct stringset *set2)
+{
+	unsigned int i = 0, j = 0;
+
+	if (WARN_ON_ONCE(!set1->ss_finalized) ||
+	    WARN_ON_ONCE(!set2->ss_finalized))
+		return false;
+	while (i < set1->ss_count && j < set2->ss_count) {
+		int cmp = strcmp(set1->ss_strings[i], set2->ss_strings[j]);
+
+		if (cmp == 0)
+			return true;
+		if (cmp < 0)
+			i++;
+		else
+			j++;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(stringset_intersection);

-- 
2.56.0

