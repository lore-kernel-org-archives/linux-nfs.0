Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:51079 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759279Ab0LNPYe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 10:24:34 -0500
Message-ID: <4D078BDE.8060102@kernel.org>
Date: Tue, 14 Dec 2010 16:23:10 +0100
From: Tejun Heo <tj@kernel.org>
To: linux-kernel@vger.kernel.org
CC: jgarzik@pobox.com, benh@kernel.crashing.org, mchehab@infradead.org,
        davem@davemloft.net, netdev@vger.kernel.org, cbou@mail.ru,
        dwmw2@infradead.org, zbr@ioremap.net, gregkh@suse.de,
        bfields@fieldses.org, neilb@suse.de, aelder@sgi.com,
        xfs-masters@oss.sgi.com, cl@linux-foundation.org,
        penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        netfilter-devel@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] workqueue: deprecate cancel_rearming_delayed_work[queue]()
References: <4D078B6D.5060202@kernel.org>
In-Reply-To: <4D078B6D.5060202@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There's no in-kernel user left for these two obsolete functions.  Mark
them deprecated and schedule for removal during 2.6.39 cycle.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 Documentation/feature-removal-schedule.txt |   10 ++++++++++
 include/linux/workqueue.h                  |    4 ++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 6c2f55e..4ff47de 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -564,3 +564,13 @@ Why:	This field is deprecated. I2C device drivers shouldn't change their
 Who:	Jean Delvare <khali@linux-fr.org>

 ----------------------------
+
+What:	cancel_rearming_delayed_work[queue]()
+When:	2.6.39
+
+Why:	The functions have been superceded by cancel_delayed_work_sync()
+	quite some time ago.  The conversion is trivial and there is no
+	in-kernel user left.
+Who:	Tejun Heo <tj@kernel.org>
+
+----------------------------
diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 0c0771f..6b5193d 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -401,7 +401,7 @@ static inline bool __cancel_delayed_work(struct delayed_work *work)
 }

 /* Obsolete. use cancel_delayed_work_sync() */
-static inline
+static inline __deprecated
 void cancel_rearming_delayed_workqueue(struct workqueue_struct *wq,
 					struct delayed_work *work)
 {
@@ -409,7 +409,7 @@ void cancel_rearming_delayed_workqueue(struct workqueue_struct *wq,
 }

 /* Obsolete. use cancel_delayed_work_sync() */
-static inline
+static inline __deprecated
 void cancel_rearming_delayed_work(struct delayed_work *work)
 {
 	cancel_delayed_work_sync(work);
