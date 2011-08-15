Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34784 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327Ab1HOPgi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 11:36:38 -0400
Date: Mon, 15 Aug 2011 11:36:37 -0400
To: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: open() of device special files
Message-ID: <20110815153637.GD28629@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

How is the client supposed to handle opens of device special files?  On
a 3.1-rc1-based client to a linux server over v4.0 I'm seeing it try an
OPEN call and failing when it gets an INVAL return.

This looks like bogus client behavior (OPEN should fail on such files),
unless the server has the error return wrong and the client's using an
OPEN error to recover.

If I first stat the device and then open it then it works as expected
(the client does an open of the local device).

I'm a bit annoyed at myself as I have a feeling we've discussed this
before but I can't find a reference now.

--b.
