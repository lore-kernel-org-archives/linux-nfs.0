Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:53228
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752616Ab1GaSYM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jul 2011 14:24:12 -0400
Date: Sun, 31 Jul 2011 14:24:06 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Please pull NFS client changes
Message-ID: <20110731182406.GA16470@infradead.org>
References: <1312082377.10882.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312082377.10882.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

How does this manage to include the pnfs block code, which only was posted
on the list a few hours before the pull request, and which doesn't
appear to past testing very well (although the major issue seems to be
core nfs code)?

