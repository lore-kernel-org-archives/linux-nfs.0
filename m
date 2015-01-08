Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53931 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbbAHOqA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 09:46:00 -0500
Date: Thu, 8 Jan 2015 06:45:59 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/49] *** Add Flexfile Layout Module ***
Message-ID: <20150108144559.GA11530@infradead.org>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do you also have a git tree available?  I'd like to test that the
core pnfs changes don't cause regressions for the block layout driver.

Talking about testing, where can I get the flexfiles server to test this
layout?

