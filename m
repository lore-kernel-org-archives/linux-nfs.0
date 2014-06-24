Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36049 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaFXL4W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 07:56:22 -0400
Date: Tue, 24 Jun 2014 04:56:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 013/104] NFSd: Allow lockowners to hold several
 stateids
Message-ID: <20140624115621.GC31935@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-14-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-14-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needs a good explanation on why we do this instead of having to rely
on the context in the surrounding patches.

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
