Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47295 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbaJCPKJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2014 11:10:09 -0400
Date: Fri, 3 Oct 2014 08:10:09 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Thomas Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Tom Haynes <loghyr@primarydata.com>
Subject: Re: [PATCH] NFSv4: Remove dead prototype for
 nfs4_insert_deviceid_node()
Message-ID: <20141003151009.GA9250@infradead.org>
References: <1412318651-53549-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412318651-53549-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 02, 2014 at 11:44:11PM -0700, Thomas Haynes wrote:
> From: Tom Haynes <loghyr@primarydata.com>
> 
> nfs4_insert_deviceid_node() was removed in 661373b13d0490ff410a2133d4a7a117f2dd037e

Oops, sorry.


Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
