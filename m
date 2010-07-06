Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649Ab0GFRTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 13:19:17 -0400
Date: Tue, 6 Jul 2010 13:19:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Artem Bityutskiy <dedekind1@gmail.com>,
        Thomas Gleixner <tglx@linutronix.de>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Venki Pallipadi <venkatesh.pallipadi@intel.com>
Subject: [PATCH] timers.c: document meaning of deferrable timer
Message-ID: <20100706171908.GL7387@fieldses.org>
References: <1277996756-8415-1-git-send-email-dedekind1@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1277996756-8415-1-git-send-email-dedekind1@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Steal some text from 6e453a67510 "Add support for deferrable timers".
A reader shouldn't have to dig through the git logs for the basic
description of a deferrable timer.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 kernel/timer.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/timer.c b/kernel/timer.c
index ee305c8..947bcf6 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -90,8 +90,13 @@ static DEFINE_PER_CPU(struct tvec_base *, tvec_bases) = &boot_tvec_bases;
 
 /*
  * Note that all tvec_bases are 2 byte aligned and lower bit of
- * base in timer_list is guaranteed to be zero. Use the LSB for
- * the new flag to indicate whether the timer is deferrable
+ * base in timer_list is guaranteed to be zero. Use the LSB to
+ * indicate whether the timer is deferrable.
+ *
+ * A deferrable timer will work normally when the system is busy, but
+ * will not cause a CPU to come out of idle just to service it; instead,
+ * the timer will be serviced when the CPU eventually wakes up with a
+ * subsequent non-deferrable timer.
  */
 #define TBASE_DEFERRABLE_FLAG		(0x1)
 
-- 
1.7.0.4

