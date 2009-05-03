From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: misc (mostly callback) patches for 2.6.31
Date: Sun,  3 May 2009 14:16:26 -0400
Message-ID: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58602 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
Received: from bfields by pickle.fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1M0gEx-0005NE-A5
	for linux-nfs@vger.kernel.org; Sun, 03 May 2009 14:16:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I intend to submit the following for 2.6.31, mainly concerned with
moving the nfsv4 callbacks to asynchronous rpc's.  Currently we create a
new kthread for each callback.  But there's no real reason they need a
real thread, and I'm assuming an rpc task will be lighter-weight.  This
should also keep the callbacks from outliving the nfsd module (though
that could probably be solved some other way).

Next I'd like to improve the decision about when to declare the callback
channel down, and implement the callback-parameter-changing case of
setclientid (and the corresponding 4.1 case).  For the latter I'm
currently stuck trying to decide how to do the locking necessary to
prevent races between destruction of the old rpc client and
lease-breaking code about to launch a new rpc task using the old rpc
client.

--b.
