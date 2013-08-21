Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42630 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab3HUGkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Aug 2013 02:40:03 -0400
Date: Tue, 20 Aug 2013 23:39:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/16] NFS add tracepoints
Message-ID: <20130821063958.GA3382@infradead.org>
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
 <5213D689.3030103@gmail.com>
 <1377033113.21393.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1377033113.21393.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 20, 2013 at 09:11:52PM +0000, Myklebust, Trond wrote:
> Hmm... Does the following patch fix the problem?

I think you just need to add this line to fs/nfs/Makefile:

ccflags-y += -I$(src)                   # needed for trace events

(stolen from XFS :))

