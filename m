Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53067 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbbKMInO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:43:14 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: CLONE fixes, V2
Date: Fri, 13 Nov 2015 09:38:44 +0100
Message-Id: <1447403929-13743-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resend of the clone fixes.  This includes support for intra-file CLONES
recently added to the spec, and makes the CLONE_RANGE ioctl compatible
with the original btrfs one, so that programs written for it actually
work.

