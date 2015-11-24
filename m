Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:49336 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbbKXTg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 14:36:59 -0500
Date: Tue, 24 Nov 2015 14:36:46 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
Message-ID: <20151124193646.GA3482@thunk.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the patch I would prefer to use (and in fact which I have
added to the ext4 tree):

There are issues with 32-bit vs 64-bit encoding of times before
January 1, 1970, which are handled with this patch which is not
handled with what you have in your patch series.  So I'd prefer if you
drop this patch, and I'll get this sent to Linus as a bug fix for 4.4.

Cheers,

					- Ted


commit e0d738b05d484487b7e1e3c6d537da8bbef80c86
Author: David Turner <novalis@novalis.org>
Date:   Tue Nov 24 14:34:37 2015 -0500

    ext4: Fix handling of extended tv_sec
    In ext4, the bottom two bits of {a,c,m}time_extra are used to extend
    the {a,c,m}time fields, deferring the year 2038 problem to the year
    2446.
    
    When decoding these extended fields, for times whose bottom 32 bits
    would represent a negative number, sign extension causes the 64-bit
    extended timestamp to be negative as well, which is not what's
    intended.  This patch corrects that issue, so that the only negative
    {a,c,m}times are those between 1901 and 1970 (as per 32-bit signed
    timestamps).
    
    Some older kernels might have written pre-1970 dates with 1,1 in the
    extra bits.  This patch treats those incorrectly-encoded dates as
    pre-1970, instead of post-2311, until kernel 4.20 is released.
    Hopefully by then e2fsck will have fixed up the bad data.
    
    Also add a comment explaining the encoding of ext4's extra {a,c,m}time
    bits.
    
    Signed-off-by: David Turner <novalis@novalis.org>
    Signed-off-by: Theodore Ts'o <tytso@mit.edu>
    Reported-by: Mark Harris <mh8928@yahoo.com>
    Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=23732
    Cc: stable@vger.kernel.org

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 750063f..fddce29 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -26,6 +26,7 @@
 #include <linux/seqlock.h>
 #include <linux/mutex.h>
 #include <linux/timer.h>
+#include <linux/version.h>
 #include <linux/wait.h>
 #include <linux/blockgroup_lock.h>
 #include <linux/percpu_counter.h>
@@ -727,19 +728,53 @@ struct move_extent {
 	<= (EXT4_GOOD_OLD_INODE_SIZE +			\
 	    (einode)->i_extra_isize))			\
 
+/*
+ * We use an encoding that preserves the times for extra epoch "00":
+ *
+ * extra  msb of                         adjust for signed
+ * epoch  32-bit                         32-bit tv_sec to
+ * bits   time    decoded 64-bit tv_sec  64-bit tv_sec      valid time range
+ * 0 0    1    -0x80000000..-0x00000001  0x000000000 1901-12-13..1969-12-31
+ * 0 0    0    0x000000000..0x07fffffff  0x000000000 1970-01-01..2038-01-19
+ * 0 1    1    0x080000000..0x0ffffffff  0x100000000 2038-01-19..2106-02-07
+ * 0 1    0    0x100000000..0x17fffffff  0x100000000 2106-02-07..2174-02-25
+ * 1 0    1    0x180000000..0x1ffffffff  0x200000000 2174-02-25..2242-03-16
+ * 1 0    0    0x200000000..0x27fffffff  0x200000000 2242-03-16..2310-04-04
+ * 1 1    1    0x280000000..0x2ffffffff  0x300000000 2310-04-04..2378-04-22
+ * 1 1    0    0x300000000..0x37fffffff  0x300000000 2378-04-22..2446-05-10
+ *
+ * Note that previous versions of the kernel on 64-bit systems would
+ * incorrectly use extra epoch bits 1,1 for dates between 1901 and
+ * 1970.  e2fsck will correct this, assuming that it is run on the
+ * affected filesystem before 2242.
+ */
+
 static inline __le32 ext4_encode_extra_time(struct timespec *time)
 {
-       return cpu_to_le32((sizeof(time->tv_sec) > 4 ?
-			   (time->tv_sec >> 32) & EXT4_EPOCH_MASK : 0) |
-                          ((time->tv_nsec << EXT4_EPOCH_BITS) & EXT4_NSEC_MASK));
+	u32 extra = sizeof(time->tv_sec) > 4 ?
+		((time->tv_sec - (s32)time->tv_sec) >> 32) & EXT4_EPOCH_MASK : 0;
+	return cpu_to_le32(extra | (time->tv_nsec << EXT4_EPOCH_BITS));
 }
 
 static inline void ext4_decode_extra_time(struct timespec *time, __le32 extra)
 {
-       if (sizeof(time->tv_sec) > 4)
-	       time->tv_sec |= (__u64)(le32_to_cpu(extra) & EXT4_EPOCH_MASK)
-			       << 32;
-       time->tv_nsec = (le32_to_cpu(extra) & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
+	if (unlikely(sizeof(time->tv_sec) > 4 &&
+			(extra & cpu_to_le32(EXT4_EPOCH_MASK)))) {
+#if LINUX_VERSION_CODE < KERNEL_VERSION(4,20,0)
+		/* Handle legacy encoding of pre-1970 dates with epoch
+		 * bits 1,1.  We assume that by kernel version 4.20,
+		 * everyone will have run fsck over the affected
+		 * filesystems to correct the problem.
+		 */
+		u64 extra_bits = le32_to_cpu(extra) & EXT4_EPOCH_MASK;
+		if (extra_bits == 3)
+			extra_bits = 0;
+		time->tv_sec += extra_bits << 32;
+#else
+		time->tv_sec += (u64)(le32_to_cpu(extra) & EXT4_EPOCH_MASK) << 32;
+#endif
+	}
+	time->tv_nsec = (le32_to_cpu(extra) & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
 }
 
 #define EXT4_INODE_SET_XTIME(xtime, inode, raw_inode)			       \
