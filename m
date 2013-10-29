Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42627 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab3J2NI5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:08:57 -0400
Date: Tue, 29 Oct 2013 06:08:57 -0700
From: Hellwig Christoph <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Hellwig Christoph <hch@infradead.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Message-ID: <20131029130857.GB32094@infradead.org>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
 <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
 <20131029124836.GA13482@infradead.org>
 <58212CB2-A01A-43F1-8760-5ED8ED75E081@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <58212CB2-A01A-43F1-8760-5ED8ED75E081@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 01:05:44PM +0000, Myklebust, Trond wrote:
> Imagine someone wanting to punch a 50TB hole in NTFS, for instance. It doesn't have real holes, so you'd end up needing to zero out the existing extents in that region of the file. That will take time, even with an O(nr_extents) algorithm.

That behaviour is not a hole punch, and should not be multiplexed onto
a whole punch on the wire command!  If such a use case is important
enough there should be an equivanet of the SCSI WRITE SAME command which
might make some sense to be implemented async.

We'd surely not support it in the Linux nfsd, though.
