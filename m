Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50253 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784Ab3EMPXO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 May 2013 11:23:14 -0400
Date: Mon, 13 May 2013 11:23:12 -0400
To: Trond Myklebust <trond@netapp.com>, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: 3.11 patches
Message-ID: <20130513152312.GB1931@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've added a labeled-nfs-common branch at

	git://linux-nfs.org/~bfields/linux.git labeled-nfs-common

with 3.10-rc1 + the one labeled NFS patch shared by client and server
(with just some protocol constants).

So we can all work on top of that if we want.

(Or just apply the thing separately--it's a tiny patch.)

I also pushed the minimal server 4.2 patches to the for-3.11 branch.
The actual labeled nfs server patch I'll add as soon as I hear it's
passing tests again.

--b.
