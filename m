Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34683 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181AbbGZQ76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 12:59:58 -0400
Date: Sun, 26 Jul 2015 09:59:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v2 0/8] nfs: minor cleanups and NFSv42 CLONE support
Message-ID: <20150726165958.GA24512@infradead.org>
References: <1436778368-65447-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436778368-65447-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How is your progress on the server side patches to allow testing this?

Also can you move the btrfs ioctls to the VFS and dispatch them through
a file operation?

And please add Zack and Darren to the Cc list as they involved with
local filesystem cloning, thanks!

