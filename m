From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [PATCH 3/3] SQUASHME: nfs41: get rid of READ64 in callback_xdr.c
Date: Wed, 17 Jun 2009 20:45:00 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C56C@daytona.int.panasas.com>
References: <1245259327-9403-1-git-send-email-bhalevy@panasas.com> <1245261993.5354.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:29225
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751218AbZFRArI convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 20:47:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> All 3 patches acked...

I've squashed-in all our fixes to produced a cleaned up version
of the patchset, rebased onto v2.6.30.
It is available on
git://linux-nfs.org/~bhalevy/linux-pnfs nfs41-for-2.6.31

Thanks!

Benny
