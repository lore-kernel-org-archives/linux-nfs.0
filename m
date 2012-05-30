Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353Ab2E3Sga (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 14:36:30 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1SZnl0-0004Wg-CK
	for linux-nfs@vger.kernel.org; Wed, 30 May 2012 14:36:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: exchange_id/create_session bugfixes
Date: Wed, 30 May 2012 14:36:23 -0400
Message-Id: <1338402988-17356-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan noticed a bug in testing (thanks also to Trond for analysis
there), and I noticed another bug on reviewing the code.  Plus some
cleanup.  Queueing these up for 3.5.

--b.

