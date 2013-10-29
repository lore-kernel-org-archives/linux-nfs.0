Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42731 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895Ab3J2NYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:24:21 -0400
Date: Tue, 29 Oct 2013 06:24:21 -0700
From: Hellwig Christoph <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Message-ID: <20131029132421.GA13880@infradead.org>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
 <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
 <20131029124836.GA13482@infradead.org>
 <58212CB2-A01A-43F1-8760-5ED8ED75E081@netapp.com>
 <20131029130857.GB32094@infradead.org>
 <78317EB5-0325-429B-89C8-F4092B677EC4@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <78317EB5-0325-429B-89C8-F4092B677EC4@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 01:21:26PM +0000, Myklebust, Trond wrote:
> The current draft spec even allows the client to specify a "pattern" to be written to the "hole".

That's indeed the WRITE SAME lookalike then.  At least the SCSI people
were smart enough to define an unmap bit for "hole punching" and allow
the target to reject all other versions if they don't want to support
it.

Given that NFS v4.2 isn't finalized I'd very much recommend to

 a) properly separate those case s
 b) do not make the async version mandatory
