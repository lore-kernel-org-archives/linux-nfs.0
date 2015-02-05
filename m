Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50584 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbBEOHC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:07:02 -0500
Date: Thu, 5 Feb 2015 06:07:01 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Olga.Kornievskaia@netapp.com
Subject: Re: [PATCH 2/2] NFSv4.1: Ask for no delegation on OPEN if already
 holding one
Message-ID: <20150205140701.GA3941@infradead.org>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
 <1423000784-93180-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1423000784-93180-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 03, 2015 at 04:59:44PM -0500, Trond Myklebust wrote:
> If we already hold a delegation, there should be no reason for the
> server to issue it to us again. Unfortunately, there appear to be
> servers out there that engage in this practice. While it is often
> harmless to do so, there is one case where this creates a problem
> and that is when the client is in the process of returning that
> delegation.
> This patch uses the NFSv4.1 NFS4_SHARE_WANT_NO_DELEG flag to inform
> the server not to return a delegation in these cases.

Shouldn't this be patch 1 as it's the actual bug fix that might need
backporting?
