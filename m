Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42826 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033Ab3LDIbW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 03:31:22 -0500
Date: Wed, 4 Dec 2013 00:31:18 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Antti T?nkyr? <daedalus@pingtimeout.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131204083118.GA30216@infradead.org>
References: <529CEBC3.8060505@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529CEBC3.8060505@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please just fix ntfs to do the mapping for you, EILSEQ is not an
error the VFS or applications expect either.

