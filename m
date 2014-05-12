Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51757 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbaELQL3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 12:11:29 -0400
Date: Mon, 12 May 2014 09:11:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd4 xdr encoding fixes v2
Message-ID: <20140512161128.GA1591@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <20140512082059.GC14194@infradead.org>
 <20140512160740.GE2633@pad.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512160740.GE2633@pad.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2014 at 12:07:41PM -0400, J. Bruce Fields wrote:
> On Mon, May 12, 2014 at 01:20:59AM -0700, Christoph Hellwig wrote:
> > This series seem to cause hangs during xfstests against a server on the
> > same VM.  The trace is fairly similar every the hang happens, but the
> > point at which it happens differs:
> 
> Ouch, OK, and you're sure it starts with this series?
> 
> I guess I should try to replicate it here.  Might take a copule days.

Taking your branch and resetting it to
9fa1959e976f7a6ae84f616ca669359028070c61 didn't reproduce it after
multiple runs.  I tried a bisect, but it it instead produces a different
warn on on the first iteration, which then continues to be around, but
it gone with the whole series applied:


[  171.070621] ------------[ cut here ]------------
[  171.071611] WARNING: CPU: 1 PID: 3784 at /work/hch/linux/fs/nfsd/nfs4xdr.c:3907 nfs4svc_encode_compoundres+0x16d/0x180()
[  171.074170] Modules linked in:
[  171.074959] CPU: 1 PID: 3784 Comm: nfsd Not tainted 3.15.0-rc1+ #23
[  171.076582] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  171.078117]  0000000000000009 ffff880000167cc8 ffffffff81cdfd4a 0000000000000000
[  171.080377]  0000000000000000 ffff880000167d08 ffffffff810ab6e7 ffff88007ac611a8
[  171.082631]  ffff88007ac61000[  171.083271] ------------[ cut here ]------------

