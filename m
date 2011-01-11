Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56175 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932357Ab1AKQVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:42 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Pcgya-0005dZ-Fs
	for linux-nfs@vger.kernel.org; Tue, 11 Jan 2011 11:21:40 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: server sessions patches
Date: Tue, 11 Jan 2011 11:21:20 -0500
Message-Id: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Some more patches implementing BIND_CONN_TO_SESSION and related stuff.

The server should be able to switch to a different backchannel now on
operations that explicitly add or remove sessions or connections, or
when the rpc layer notices a connection has gone down.

Testing from the Windows people suggests we should also switch on
callback timeouts to deal with cases where one connection is unreliable.
I'm not quite sure what to do there.

I was planning on merging this for 2.6.38.  I let it get a little late.
But this seems low-risk for versions < 4.1, so I might still go ahead.

--b.

