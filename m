Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44754 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437Ab1JQV4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:23 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RFvAU-0003rU-RO
	for linux-nfs@vger.kernel.org; Mon, 17 Oct 2011 17:56:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: fix for open leaks, for 3.2
Date: Mon, 17 Oct 2011 17:55:49 -0400
Message-Id: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan Schumaker noticed that we have a longstanding leak of an open
owner each time the first open with a new open owner fails.

The following patches fix that, along with a few other less likely leaks
that occur if a memory allocation fails after a file is created.

I intend to commit these to for-3.2.  Any review welcomed.

--b.
