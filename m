Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49018 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab3JPHTV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 03:19:21 -0400
Date: Wed, 16 Oct 2013 00:19:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] exportfs: slight reorganization of reconnect loop
Message-ID: <20131016071920.GC28671@infradead.org>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
 <1381869574-10662-5-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381869574-10662-5-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 04:39:32PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Just cleanup, no change in functionality

Looks reasonable, but as said I'd have just turned the root check into a
BUG_ON earlier.

