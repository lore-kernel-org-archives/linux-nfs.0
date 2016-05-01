Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55362 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbcEARhi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 May 2016 13:37:38 -0400
Date: Sun, 1 May 2016 10:37:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
Message-ID: <20160501173733.GA556@infradead.org>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I might sound like a broken record, but I'd feel much happier if this
had extensive xfstests coverage.  Xfstests has over one hundred tests for
file clones, and many of them should be easily adapatable.
