Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60700 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377Ab0CIWel (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 17:34:41 -0500
Date: Tue, 9 Mar 2010 17:36:06 -0500
To: iisaman@citi.umich.edu
Cc: linux-nfs@vger.kernel.org
Subject: pynfs
Message-ID: <20100309223606.GA29261@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Currently some of the pynfs tests handle delay errors by sleeping up to
20 seconds.  This can cause spurious failures in some cases if your
lease time happens to be less than 20 seconds.

An ideal fix might be to query the lease time and use it as an upper
bound for those delays.

Alternatively, we could set the maximum very small, and/or just document
a minimum acceptable server lease time.  But it's tempting to set the
lease time to something very short when running the pynfs tests, since
it can make a huge difference to their run-time.

Just noting the problem for future reference....

--b.
