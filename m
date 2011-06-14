Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58443 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab1FNO6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 10:58:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: nfs-utils crossmnt bugfix, and cleanup
Date: Tue, 14 Jun 2011 10:58:08 -0400
Message-Id: <1308063492-30103-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We've long had a bug with crossmnt handling which could cause a parent's
export options to override those of a child in some cases.

While I was there, I also did some cleanup, mainly of nfsd_fh().  It was
long and complicated, now it's short and complicated.  We could probably
simplify the logic with a little more work.

--b.
