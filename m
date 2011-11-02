Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab1KBR56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 13:57:58 -0400
Date: Wed, 2 Nov 2011 18:53:27 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Tejun Heo <tj@kernel.org>, Jeff Layton <jlayton@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Steve French <sfrench@samba.org>,
        linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-cifs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH] wait_event_freezekillable: use
	freezer_do_not_count/freezer_count
Message-ID: <20111102175327.GA4446@redhat.com>
References: <20111101041337.39077229@tlielax.poochiereds.net> <20111101065958.50addab5@tlielax.poochiereds.net> <20111101163059.GR18855@google.com> <20111101175953.GB5358@redhat.com> <20111101180601.GV18855@google.com> <20111101181329.GA6739@redhat.com> <20111101182753.GW18855@google.com> <20111101193923.GA9444@redhat.com> <20111101194601.GB9444@redhat.com> <20111101215710.GA13803@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111101215710.GA13803@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fake_signal_wake_up() should not wake up the TASK_KILLABLE tasks,
we are going to fix this. This means that wait_event_freezekillable()
can't rely on wakeup from freezer. Reimplement it using
freezer_do_not_count/freezer_count. This is not really nice, just
a simple fix for now.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/freezer.h |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -143,13 +143,9 @@ static inline void set_freezable_with_si
 #define wait_event_freezekillable(wq, condition)			\
 ({									\
 	int __retval;							\
-	for (;;) {							\
-		__retval = wait_event_killable(wq,			\
-				(condition) || freezing(current));	\
-		if (__retval || (condition))				\
-			break;						\
-		try_to_freeze();					\
-	}								\
+	freezer_do_not_count();						\
+	__retval = wait_event_killable(wq, (condition));		\
+	freezer_count();						\
 	__retval;							\
 })
 

