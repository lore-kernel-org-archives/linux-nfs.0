Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38335 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932819AbaGUPwf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:52:35 -0400
Date: Mon, 21 Jul 2014 08:52:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 05/10] nfsd: ensure that clp->cl_revoked list is
 protected by clp->cl_lock
Message-ID: <20140721155228.GB4881@infradead.org>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
 <1405949706-27757-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405949706-27757-6-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
