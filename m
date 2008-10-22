From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: minor locks/grace cleanup
Date: Wed, 22 Oct 2008 17:03:19 -0400
Message-ID: <1224709402-6976-1-git-send-email-bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42793 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024AbYJVVDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 17:03:23 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1KskrS-0001p2-Cm
	for linux-nfs@vger.kernel.org; Wed, 22 Oct 2008 17:03:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The following patches are some grace-period checking cleanups I intend
to queue up for 2.6.29.

--b.
