Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38451 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699Ab0H0VGm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Aug 2010 17:06:42 -0400
Date: Fri, 27 Aug 2010 17:06:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Artem.Bityutskiy@nokia.com
Cc: bjschuma@netapp.com, jaxboe@fusionio.com, linux-nfs@vger.kernel.org,
        trond@netapp.com, hch@lst.de
Subject: Re: hang in writeback code on nfsv4 mount
Message-ID: <20100827210626.GB27694@fieldses.org>
References: <20100825023425.GA24591@fieldses.org>
 <1282889595.2763.14.camel@localhost>
 <1282901780.12016.54.camel@localhost>
 <4C77B873.8010306@netapp.com>
 <20100827160912.GA18790@fieldses.org>
 <10B234E0D3A1CA469E00963BF106CA392D0DB78354@NOK-EUMSG-02.mgdnok.nokia.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <10B234E0D3A1CA469E00963BF106CA392D0DB78354@NOK-EUMSG-02.mgdnok.nokia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 27, 2010 at 06:17:36PM +0200, Artem.Bityutskiy@nokia.com wrote:
> I need to look more. But so far I do not really understand what could make kthread_stop() wait
> forever. I looked into the code, and thought may be barriers are missing there, but I is unlikely
> this generic type of code would have bugs.

Hm, is the way you go to sleep in the writeback thread safe?  Surely
there's a race like:

while(!kthread_should_stop()) {

				kthread_stop():
					kthread->should_stop = 1;
					wake_up_process(k);
					wait_for_completion(&kthread->exited);

	/* oops, lose the wake_up here: */
	set_current_state(TASK_INTERRUPTIBLE);
	...
	/* sleep forever: */
	schedule();

Maybe the following?

--b.

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 7d9d06b..ea76550 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -808,7 +808,7 @@ int bdi_writeback_thread(void *data)
 			wb->last_active = jiffies;
 
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (!list_empty(&bdi->work_list)) {
+		if (!list_empty(&bdi->work_list) || kthread_should_stop()) {
 			__set_current_state(TASK_RUNNING);
 			continue;
 		}
