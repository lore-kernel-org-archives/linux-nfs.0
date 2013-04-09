Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50137 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935515Ab3DIX6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:21 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UPiQd-0001pW-EA
	for linux-nfs@vger.kernel.org; Tue, 09 Apr 2013 19:58:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: finishing off 4.1 for 3.10...
Date: Tue,  9 Apr 2013 19:58:05 -0400
Message-Id: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following close off 3 remaining 4.1 todo's and fix some
miscellaneous bugs and ugliness along the way.

I had two more todo's in mind before considering 4.1 no longer
experimental and turn it on by default:

	- AUTH_GSS for the backchannel
	- SP4_MACH_CRED state protection

In theory they're both mandatory, but I think I may just go ahead
without them, after making sure we return reasonable errors in both
cases and so on.

The last patch (implementing SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
hasn't gotten any real testing--I need to write a pynfs test for the
TEST_STATEID/FREE_STATEID behavior.  So that may still need some more
revisions.

I think the others are ready if nobody sees problems.

--b.
