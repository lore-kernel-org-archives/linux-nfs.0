Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38847 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329AbbLGT2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 14:28:07 -0500
Date: Mon, 7 Dec 2015 11:28:07 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v1 3/3] NFS: Add COPY nfs operation
Message-ID: <20151207192806.GC8318@infradead.org>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1449176137-4940-4-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449176137-4940-4-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2015 at 03:55:36PM -0500, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> This adds the copy_range file_ops function pointer used by the
> sys_copy_range() function call.  This patch only implements sync copies,
> so if an async copy happens we decode the stateid and ignore it.

What is the user visible behavior if a server doesn't set
cr_synchronous? I can't see any explicit handling of it, which makes
me a little sceptic that everything is just going to work fine.
