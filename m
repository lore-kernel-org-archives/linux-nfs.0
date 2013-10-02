Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44867 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740Ab3JBR53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 13:57:29 -0400
Date: Wed, 2 Oct 2013 10:57:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20131002175727.GA29467@infradead.org>
References: <20130912160324.GE1462@fieldses.org>
 <20130912193328.GP13318@ZenIV.linux.org.uk>
 <20130929115454.GA3953@infradead.org>
 <20131002142527.GD14808@fieldses.org>
 <20131002160527.GB23875@infradead.org>
 <20131002175328.GF14808@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002175328.GF14808@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Something like this?

Looks good, although I'd split it into two separate patches for the VFS
and exportfs bits.

Reviewed-by: Christoph Hellwig <hch@lst.de>
