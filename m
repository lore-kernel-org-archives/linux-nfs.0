Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41583 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbaFQN5a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 09:57:30 -0400
Date: Tue, 17 Jun 2014 06:57:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 4/4] nfsd: add appropriate __force directives to
 filehandle generation code
Message-ID: <20140617135727.GD13980@infradead.org>
References: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
 <1403005454-7319-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403005454-7319-5-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2014 at 07:44:14AM -0400, Jeff Layton wrote:
> The filehandle structs all use host-endian values, but will sometimes
> stuff big-endian values into those fields. This is OK since these
> values are opaque to the client, but it confuses sparse. Add __force to
> make it clear that we are doing this intentionally.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
