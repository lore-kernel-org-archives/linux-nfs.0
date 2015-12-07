Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36706 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120AbbLGTXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 14:23:19 -0500
Date: Mon, 7 Dec 2015 11:23:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v1 0/4] NFSv4.2: Add support for the COPY operation
Message-ID: <20151207192319.GA8318@infradead.org>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, Al has merged the clone work in for-next, so this might need
a rebase on top of that.
