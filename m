Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755266Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1Np9ma-00087e-OE
	for linux-nfs@vger.kernel.org; Tue, 09 Mar 2010 19:28:16 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Subject: allowing client to change callback path
Date: Tue,  9 Mar 2010 19:28:05 -0500
Message-Id: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The 4.0 spec allows clients to change the callback connection parameters
with an appropriate SETCLIENTID/SETCLIENTID_CONFIRM, but we've never
implemented that.  Here's an attempt.

The real goal is to later use this to implement BIND_CONN_TO_SESSION.
Since that's the only way I see for a client to recover the backchannel
after a tcp connection without losing the session state, I figure 4.1
clients may be more likely to need this than 4.0 clients?

The first 7 patches are probably ready to go.  The first two are to
client-side code.  Trond, if you could ACK them, I'll queue them up in
the server tree.  (Actually, the first could go now if it looks right.)

The rest of the patches are closer to an RFC, and are barely tested.  I
avoid sleeping in the cb_recall callback by deferring the real work to a
workqueue, and then use the same trick to requeue a callback after the
callback client changes.

--b.
