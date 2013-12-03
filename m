Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38700 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab3LCJpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Dec 2013 04:45:07 -0500
Date: Tue, 3 Dec 2013 01:45:07 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fs: fix iversion handling
Message-ID: <20131203094507.GD4906@infradead.org>
References: <20131119151707.GA13412@infradead.org>
 <20131202173636.GA17724@infradead.org>
 <529DA5C6.7040403@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529DA5C6.7040403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 11:35:02AM +0200, Boaz Harrosh wrote:
> Hi Christoph
> 
> What happens with all other filesystems exported under KNFSD?
> 
> As I understand inode_inc_iversion() is used in NFSv4 and up,
> what will increment the inode-version on changed attributes
> for them?

It's used by the filesystem for the change attribute that NFSDd
can optionally use.  Most filesystsems don't support it and work
okay enough when NFS exported.  No other filesystem will need
to adopt for this patch specificly, given that no other filesystem
uses this infrastructure.

