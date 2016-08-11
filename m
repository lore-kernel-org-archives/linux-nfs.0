Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42604 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbcHKRis (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 13:38:48 -0400
Date: Thu, 11 Aug 2016 19:38:46 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trondmy@primarydata.com>, hch@lst.de
Subject: Re: [PATCH] nfsd: don't set a FL_LAYOUT lease for flexfiles layouts
Message-ID: <20160811173846.GA26263@lst.de>
References: <1470936982-14409-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1470936982-14409-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks fine to me, although it might be a good idea to just
have a flags field in the layout_ops structure for additional
quirks in the future instead of the boolean.
