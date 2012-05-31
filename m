Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50069 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756295Ab2EaBuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 21:50:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: rename locking
Date: Wed, 30 May 2012 21:50:10 -0400
Message-Id: <1338429016-20119-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a resend of the rename locking patches.  With the quota locking
cleaned up, it looks safe to move ext4's locking into common code and
then use that.

Steven Whitehouse has another plan for gfs2, but last I talked to him
was OK with Jan Kara's fix for now.

--b.

