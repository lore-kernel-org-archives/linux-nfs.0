Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:47458 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbaIIRhY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 13:37:24 -0400
Date: Tue, 9 Sep 2014 19:37:21 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/9] pnfs: force a layout commit when encountering busy
	segments during recall
Message-ID: <20140909173721.GA24573@lst.de>
References: <1410280853-3964-1-git-send-email-hch@lst.de> <1410280853-3964-2-git-send-email-hch@lst.de> <540F34CF.7080709@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <540F34CF.7080709@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 09, 2014 at 01:11:43PM -0400, Anna Schumaker wrote:
> Any reason for the occasional spacing changes in this patch?

That's a leftover from the previous version I guess..

