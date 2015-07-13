Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55411 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbbGMG6w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 02:58:52 -0400
Date: Sun, 12 Jul 2015 23:58:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
Message-ID: <20150713065851.GD26245@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also please include a server side implementation.  Adding Linux NFS
client features that don't also have server support have been proven
to be untestable.

Here is my prototype for an older draft, which can be brought forward
easily: http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone

