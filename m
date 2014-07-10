Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39394 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaGJKcI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 06:32:08 -0400
Date: Thu, 10 Jul 2014 03:32:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 009/100] nfsd: Add locking to the nfs4_file->fi_fds[]
 array
Message-ID: <20140710103206.GB6935@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-10-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 02:02:57PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Preparation for removal of the client_mutex, which currently protects
> this array.

Looks good, although it might be a bit cleaner if you fold the addition
of the _locked version in a later patch into this one.

Reviewed-by: Christoph Hellwig <hch@lst.de>
