Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:33945 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbaEFRfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 May 2014 13:35:01 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: get rid of include/linux/nfsd
Date: Tue,  6 May 2014 19:37:12 +0200
Message-Id: <1399397836-31948-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that all user-visible headers are in include/uapi there is nothing
left there which shouldn't rather be under fs/nfsd/.

