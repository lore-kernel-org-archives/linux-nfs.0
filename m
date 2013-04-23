Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38311 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394Ab3DWVO0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 17:14:26 -0400
Date: Tue, 23 Apr 2013 17:14:25 -0400
To: "linux.pnfs" <linux.pnfs@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: pNFS layered over cluster FS, is this the status quo?
Message-ID: <20130423211425.GK3676@fieldses.org>
References: <201304211613254596282@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201304211613254596282@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 21, 2013 at 04:13:27PM +0800, linux.pnfs wrote:
> pNFS layered over cluster FS(such as GFS2), DLM implement layoutget(a pnfs export operations) but it not support IOMODE_RW, that is write data must via meta data server, -->> is this the status quo?
> 
> the MDS' layoutget will support IOMODE_RW and client will RW data via data server in the future?
> or is there any support for: howto parellel R&W data via data server?

This is up to the implementation.

The linux gfs2 pnfs patches implement a very simple prototype.

--b.
