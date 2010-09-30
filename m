Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49109 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab0I3QT2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:28 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P1Lqn-0002OQ-Ct
	for linux-nfs@vger.kernel.org; Thu, 30 Sep 2010 12:19:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: 4.1 patches
Date: Thu, 30 Sep 2010 12:18:57 -0400
Message-Id: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I've been working on fixing the server's sessions to bring the sessions
and trunking requirements up to spec.

I'm still implementing and debugging the patches that do that, but
the following patches do some initial cleanup (amd minor bugfixes) that
I found along the way, so I'm probably ready to queue these up for
2.6.37 absent any objections.

They also add a list of connections associated with each session, though
that's not yet used for anything important.  (I do use it to enforce the
requirement that DESTROY_SESSION be sent over a connection already
associated with that session.  As has been pointed out on the ietf list,
the basis for that requirement is a little murky, so I may back out that
last patch--for now it at least gives me an easy way to check (using a
pynfs41 DESTROY_SESSION test) that the list of connections is correct).)

--b.
