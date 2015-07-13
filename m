Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55580 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbbGMHAB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:00:01 -0400
Date: Mon, 13 Jul 2015 00:00:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/9] SUNRPC: Drop double-underscores from
 rpc_cmp_addr{4|6}()
Message-ID: <20150713070000.GG26245@infradead.org>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1436561897-8051-4-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436561897-8051-4-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 04:58:11PM -0400, Anna Schumaker wrote:
> I'm planning on using these functions inside the client, so remove the
> underscores to make it feel like I'm using a public interface.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
