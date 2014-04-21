Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34306 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaDUGmH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 02:42:07 -0400
Date: Sun, 20 Apr 2014 23:42:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
Message-ID: <20140421064204.GA19231@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 05:09:24PM -0400, Anna Schumaker wrote:
> Questions?  Comments?  Death threats?

Can you say what tree this is based on or even better publish a git
tree?  I tried to apply the series to various trees so that I can get a
better picture for further reviews, but git-am always bailed out
somewhere.

