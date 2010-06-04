From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [pnfs] [PATCH 3/3] pnfs-blocklayout client: add block device
	pipe processing based on simple rpc pipefs
Date: Fri, 4 Jun 2010 14:25:06 -0400
Message-ID: <20100604182506.GA22000@infradead.org>
References: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com> <op.vdsfn9iounckof@usensfaibisl2e.eng.emc.com> <op.vdsfuksdunckof@usensfaibisl2e.eng.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Benny Halevy <bhalevy@panasas.com>,
	"pnfs@linux-nfs.org" <pnfs@linux-nfs.org>
To: sfaibish <sfaibish@emc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37440 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab0FDSZH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jun 2010 14:25:07 -0400
In-Reply-To: <op.vdsfuksdunckof-sXut7+96orlxdPWQvOaHCoI83tS8F2Zb0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Btw, simple reminder that all this has zero chance of going upstream
until someone addresses the issue of a proper API for locking down the
device mappings and getting the final block mapping in kernelspace.

