Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:37325 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbbCOM6Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Mar 2015 08:58:25 -0400
Date: Sun, 15 Mar 2015 13:58:21 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150315125821.GA10655@lst.de>
References: <20150303221033.GB19439@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150303221033.GB19439@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2015 at 05:10:33PM -0500, J. Bruce Fields wrote:
> I'm getting mysterious crashes on a server exporting an xfs filesystem.

Can you shared the setup used to reproduce the various issues in this thread?
I've been trying ot get a baseline, but even withotu CONFIG_NFSD_PNFS set
I start to run into other prolems early on, so I suspect the reproducer might
be something else?
