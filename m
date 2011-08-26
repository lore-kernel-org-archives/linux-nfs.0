Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53237 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Qx4tF-0004qa-8X
	for linux-nfs@vger.kernel.org; Fri, 26 Aug 2011 18:28:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: miscellaneous nfsd (mainly v4 state) cleanup & bugfixes
Date: Fri, 26 Aug 2011 18:28:21 -0400
Message-Id: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is some cleanup (and smaller bugfixes) done mainly on the way to
other stuff.

Mainly just getting rid of cruft:

 12 files changed, 273 insertions(+), 385 deletions(-)

--b.
