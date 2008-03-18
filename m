From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: asynchronous destroy messages
Date: Tue, 18 Mar 2008 18:15:15 -0400
Message-ID: <20080318221515.GE29948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161639AbYCSWcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 18:32:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an rpc client is shut down, gss destroy messages are sent out
asynchronously, and nobody waits for them.

If those rpc messages arrive after the client is completely shut down, I
assume they just get dropped by the networking code?  Is it possible for
them to arrive while we're still in the process of shutting down, and if
so, what makes this safe?

Olga's seeing some odd oopses on shutdown after testing our gss callback
code.  And of course it's probably our callback patches at fault, but I
was starting to wonder if there was a problem with those destroy
messages arriving at the wrong moment.  Any pointers welcomed.

--b.
