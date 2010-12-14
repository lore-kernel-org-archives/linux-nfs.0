Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47672 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758540Ab0LNVDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 16:03:11 -0500
Date: Tue, 14 Dec 2010 16:03:10 -0500
To: linux-nfs@vger.kernel.org
Cc: Tom Tucker <tom@opengridcomputing.com>
Subject: 4.1 and rdma
Message-ID: <20101214210310.GI24828@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I asked Tom Tucker what he thought would be the minimum needed for our
4.1 implementation to be up-to-spec with regard to RDMA, and he took a
first look through the spec and made some notes:

	http://wiki.linux-nfs.org/wiki/index.php/4.1_RDMA_issues

I don't know any big rush for 4.1/rdma, just wanted to make sure we
weren't doing anything that would make it hard to do it right later.

On the server side I think the safest thing to do may be just to return
an error on a CREATE_SESSION that arrives over an rdma connection, at
least until we figure out what more we'd need to do to support it
correctly?

--b.
