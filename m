Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42747 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758428Ab3ENVMz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:12:55 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UcMWk-0004Mo-Tl
	for linux-nfs@vger.kernel.org; Tue, 14 May 2013 17:12:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: 
Date: Tue, 14 May 2013 17:12:50 -0400
Message-Id: <1368565973-16739-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following is a minimal SP4_MACH_CRED implementation.  I plan to
queue it up for 3.11.

It could use some testing at least, though.

--b.

