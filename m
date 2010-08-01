Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33185 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab0HATpZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 15:45:25 -0400
Date: Sun, 1 Aug 2010 15:45:02 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Ingo Molnar <mingo@elte.hu>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] NFS: Fix build failure on !CONFIG_NFS_V3 &&
 !CONFIG_NFS_V3
Message-ID: <20100801194502.GA3801@infradead.org>
References: <1280519035.12852.32.camel@heimdal.trondhjem.org>
 <20100801064415.GA10523@elte.hu>
 <AANLkTim=6q1FC8YZvmi2Cju_6+00mHHkNPpCLHB8e3=h@mail.gmail.com>
 <1280684100.4430.8.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1280684100.4430.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Btw, is there a reason to allow not building NFSv3?  If at all
building without v2 support would be more useful.

