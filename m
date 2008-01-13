From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Sun, 13 Jan 2008 18:17:43 +0000
Message-ID: <20080113181743.GA20219@infradead.org>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com> <1199820798-5289-2-git-send-email-jlayton@redhat.com> <1199820798-5289-3-git-send-email-jlayton@redhat.com> <1199820798-5289-4-git-send-email-jlayton@redhat.com> <20080109173542.GA30523@infradead.org> <20080113082718.396890f7@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51745 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbYAMSRx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jan 2008 13:17:53 -0500
In-Reply-To: <20080113082718.396890f7-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 13, 2008 at 08:27:18AM -0500, Jeff Layton wrote:
>    I've been hitting an intermittent null pointer dereference ever
> since I've made this change:

The first thing lockd does is to call lock_kernel().  This may either
block (or spin) when it is contended and thus delay updating
nlmsvc_serv.  Now lockd_up checks for nlmsvc_task which already is
non-NULL and happily dereference nlmsvc_serv.   The patch below
updates nlmsvc_serv in lockd_up where it is protected by nlmsvc_mutex
and also checks for nlmsvc_serv beeing set instead of nlmsvc_task to
fix this problem.

The patch hasn't actually been tested but I'm sure it will fix this
issue.

Btw, lockd() takes BKL just after starting up and only implicitly drops
it when blocking.  This seems very dangerous to me and badly wants
updating to some real locking scheme..


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/lockd/svc.c
===================================================================
--- linux-2.6.orig/fs/lockd/svc.c	2008-01-13 19:07:17.000000000 +0100
+++ linux-2.6/fs/lockd/svc.c	2008-01-13 19:13:23.000000000 +0100
@@ -118,7 +118,6 @@ lockd(void *vrqstp)
 
 	/* set up kernel thread */
 	lock_kernel();
-	nlmsvc_serv = rqstp->rq_server;
 	set_freezable();
 
 	/* Allow SIGKILL to tell lockd to drop all of its locks */
@@ -253,7 +252,7 @@ lockd_up(int proto) /* Maybe add a 'fami
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_task) {
+	if (nlmsvc_serv) {
 		if (proto)
 			error = make_socks(nlmsvc_serv, proto);
 		goto out;
@@ -290,6 +289,9 @@ lockd_up(int proto) /* Maybe add a 'fami
 	}
 
 	svc_sock_update_bufs(serv);
+
+	nlmsvc_serv = rqstp->rq_server;
+
 	nlmsvc_task = kthread_run(lockd, rqstp, serv->sv_name);
 	if (IS_ERR(nlmsvc_task)) {
 		error = PTR_ERR(nlmsvc_task);
