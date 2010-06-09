Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56216 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349Ab0FIAMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 20:12:36 -0400
Date: Tue, 8 Jun 2010 20:12:32 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: sfaibish <sfaibish@emc.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@panasas.com>,
        "pnfs@linux-nfs.org" <pnfs@linux-nfs.org>
Subject: Re: [pnfs] [PATCH 3/3] pnfs-blocklayout client: add block device
	pipe processing based on simple rpc pipefs
Message-ID: <20100609001232.GM26435@fieldses.org>
References: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com> <op.vdsfn9iounckof@usensfaibisl2e.eng.emc.com> <op.vdsfuksdunckof@usensfaibisl2e.eng.emc.com> <20100604182506.GA22000@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100604182506.GA22000@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 04, 2010 at 02:25:06PM -0400, Christoph Hellwig wrote:
> Btw, simple reminder that all this has zero chance of going upstream
> until someone addresses the issue of a proper API for locking down the
> device mappings and getting the final block mapping in kernelspace.

Do you have any more details on the issue?  (Reference to a previous
thread?)

My (probably faulty) understanding of the the basic idea of the patches:
a list of block signatures and a description of the desired topology is
passed up to a userspace daemon, and the daemon cobbles together a
device and passes down device major/minor numbers for the result.

Are major/minor numbers the right way to hand off the device?  (And what
do you mean by "locking down the device mappings"?  Is there a
possibility the device can be destroyed while the kernel's using it?)

--b.
