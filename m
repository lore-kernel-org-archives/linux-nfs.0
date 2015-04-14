Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56212 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbbDNTWW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 15:22:22 -0400
Date: Tue, 14 Apr 2015 12:22:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Remove CONFIG_NFS_V4 checks from nfs_idmap.h
Message-ID: <20150414192217.GA20599@infradead.org>
References: <1429036032-11204-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1429036032-11204-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 14, 2015 at 02:27:12PM -0400, Anna Schumaker wrote:
> The idmapper is completely internal to the NFS v4 module, so this macro
> will always evaluate to true.  This patch also removes unnecessary
> includes of this file from the generic NFS client.


Reviewed-by: Christoph Hellwig <hch@lst.de>

Seems like the header should move to fs/nfs/ as well..
