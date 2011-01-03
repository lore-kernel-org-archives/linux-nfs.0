Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab1ACSa4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 13:30:56 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1PZpBI-0004gn-Ac
	for linux-nfs@vger.kernel.org; Mon, 03 Jan 2011 13:30:56 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: nfsd cache_check fix and change to nfserr_dropit handling
Date: Mon,  3 Jan 2011 13:30:49 -0500
Message-Id: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A little more bugfixing and cleanup to be queued up for 2.6.38 if nobody
sees a problem with it.

--b.
