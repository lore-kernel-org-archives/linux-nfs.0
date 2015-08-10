Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38361 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbbHJNN6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 09:13:58 -0400
Date: Mon, 10 Aug 2015 06:13:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: nfs-utils regression on IPv6-less kernels
Message-ID: <20150810131358.GA19466@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

since commit "ipv6: Enable IPv6 support by default." rpc.mountd
fails to start on a kernel without IPv6 support.  Seems like it
doesn't have a proper fallback if an address family isn't implemented.
