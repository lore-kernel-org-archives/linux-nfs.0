Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35800 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbbHJMIW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2015 08:08:22 -0400
Date: Mon, 10 Aug 2015 14:08:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: xfstests crash with trond/testing
Message-ID: <20150810120820.GA11618@lst.de>
References: <20150808142040.GA9456@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150808142040.GA9456@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Correction:  This was a plain 4.1 mount, not using pnfs at all, it
reproduces every time I do a full xfstests run.
