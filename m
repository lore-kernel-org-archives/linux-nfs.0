Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37488 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542Ab3J1Ixt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 04:53:49 -0400
Date: Mon, 28 Oct 2013 01:53:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/8] exportfs: stop retrying once we race with
 rename/remove
Message-ID: <20131028085348.GA3673@infradead.org>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
 <1382733005-6006-5-git-send-email-bfields@redhat.com>
 <20131027180409.66037e01@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131027180409.66037e01@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 27, 2013 at 06:04:09PM +1100, NeilBrown wrote:
> This looks remarkably similar to find_disconnected_root().

It does, but that function is going away in the last patch of the
series.

