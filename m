Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139Ab3BOTXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 14:23:07 -0500
Date: Fri, 15 Feb 2013 14:23:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@start.ca>
Cc: Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>,
        Tom Horsley <horsley1953@gmail.com>,
        Jason Tibbitts <tibbs@math.uh.edu>
Subject: [PATCH 1/2] svcrpc: make svc_age_temp_xprts enqueue under sv_lock
Message-ID: <20130215192303.GD19923@fieldses.org>
References: <50F63882.8000607@parallels.com>
 <50F72F03.5070806@teksavvy.com>
 <50F786AF.4070107@parallels.com>
 <20130117130335.GD6598@fieldses.org>
 <50F7FB7E.2020503@parallels.com>
 <50F88C14.7030903@teksavvy.com>
 <50F8DF7E.8080107@parallels.com>
 <50FC74E0.20305@teksavvy.com>
 <20130212205216.GE10267@fieldses.org>
 <511BAAAA.9040804@start.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <511BAAAA.9040804@start.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_age_temp_xprts expires xprts in a two-step process: first it takes
the sv_lock and moves the xprts to expire off their server-wide list
(sv_tempsocks or sv_permsocks) to a local list.  Then it drops the
sv_lock and enqueues and puts each one.

I see no reason for this: svc_xprt_enqueue() will take sp_lock, but the
sv_lock and sp_lock are not otherwise nested anywhere (and documentation
at the top of this file claims it's correct to nest these with sp_lock
inside.)

Cc: stable@kernel.org
Tested-by: Jason Tibbitts <tibbs@math.uh.edu>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5a9d40c..11a33c8 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -863,7 +863,6 @@ static void svc_age_temp_xprts(unsigned long closure)
 	struct svc_serv *serv = (struct svc_serv *)closure;
 	struct svc_xprt *xprt;
 	struct list_head *le, *next;
-	LIST_HEAD(to_be_aged);
 
 	dprintk("svc_age_temp_xprts\n");
 
@@ -884,25 +883,15 @@ static void svc_age_temp_xprts(unsigned long closure)
 		if (atomic_read(&xprt->xpt_ref.refcount) > 1 ||
 		    test_bit(XPT_BUSY, &xprt->xpt_flags))
 			continue;
-		svc_xprt_get(xprt);
-		list_move(le, &to_be_aged);
+		list_del_init(le);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		set_bit(XPT_DETACHED, &xprt->xpt_flags);
-	}
-	spin_unlock_bh(&serv->sv_lock);
-
-	while (!list_empty(&to_be_aged)) {
-		le = to_be_aged.next;
-		/* fiddling the xpt_list node is safe 'cos we're XPT_DETACHED */
-		list_del_init(le);
-		xprt = list_entry(le, struct svc_xprt, xpt_list);
-
 		dprintk("queuing xprt %p for closing\n", xprt);
 
 		/* a thread will dequeue and close it soon */
 		svc_xprt_enqueue(xprt);
-		svc_xprt_put(xprt);
 	}
+	spin_unlock_bh(&serv->sv_lock);
 
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
 }
-- 
1.7.9.5

