Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48152 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbbAGO44 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 09:56:56 -0500
Date: Wed, 7 Jan 2015 06:56:55 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 05/49] nfs41: pull nfs4_ds_connect from file layout to
 generic pnfs
Message-ID: <20150107145655.GB6019@infradead.org>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <1420590534-84063-6-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420590534-84063-6-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 04:28:10PM -0800, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> It can be reused by flexfiles layout client.

The patch doesn't actually move any code, it just removes code.
