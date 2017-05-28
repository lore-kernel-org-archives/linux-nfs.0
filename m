Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:56688 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdE1Gfa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 May 2017 02:35:30 -0400
Date: Sat, 27 May 2017 23:35:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] fs/locks: Alloc file_lock where practical
Message-ID: <20170528063520.GA32640@infradead.org>
References: <cover.1495829587.git.bcodding@redhat.com>
 <1588d987ebffd963a71b0ac23d73d11b34142d15.1495829587.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1588d987ebffd963a71b0ac23d73d11b34142d15.1495829587.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 26, 2017 at 04:14:49PM -0400, Benjamin Coddington wrote:
> Use an allocation it where makes sense to do so.

Care to expain why it makes sense?
