Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33276 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbcBHSd2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2016 13:33:28 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1aSqcq-00029E-Hk
	for linux-nfs@vger.kernel.org; Mon, 08 Feb 2016 18:33:28 +0000
Date: Mon, 8 Feb 2016 10:33:28 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: silent truncation for large file offsets
Message-ID: <20160208183328.GA29982@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

