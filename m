Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35532 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab2KZOkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:02 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1Tczqr-00034j-UZ
	for linux-nfs@vger.kernel.org; Mon, 26 Nov 2012 09:40:02 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: fixes for 3.8
Date: Mon, 26 Nov 2012 09:39:51 -0500
Message-Id: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following are some fixes I plan to queue up for 3.8, mostly problems
found while looking at the v4 xdr code.

--b.

