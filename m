Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:43869 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650AbaKHMK6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 07:10:58 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: nfsd: add support for the chage_attr_type attribute
Date: Sat,  8 Nov 2014 13:11:02 +0100
Message-Id: <1415448664-25815-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first one is a bug fix that probably should go into 3.18-rc and -stable.

