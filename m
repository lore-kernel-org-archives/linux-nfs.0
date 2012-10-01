Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43324 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566Ab2JARqy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:54 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TIk50-0007up-8r
	for linux-nfs@vger.kernel.org; Mon, 01 Oct 2012 13:46:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: 4.1 session allocation cleanup
Date: Mon,  1 Oct 2012 13:46:44 -0400
Message-Id: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following cleanup is preparation for some locking changes that
aren't actually ready to merge yet--but I don't see any reason not to go
ahead and merge the cleanup for 3.7.

--b.

