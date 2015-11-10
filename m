Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33583 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbKJL3x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2015 06:29:53 -0500
Date: Tue, 10 Nov 2015 03:29:43 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v15 00/22] Richacls (Core and Ext4)
Message-ID: <20151110112943.GA17038@infradead.org>
References: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 09, 2015 at 12:08:41PM +0100, Andreas Gruenbacher wrote:
> Here is another update to the richacl patch queue.  This posting contains
> the patches ready to be merged; the patches later in the queue still need
> some more review.

It still has the same crappy fs interfaces with lots of boilerplate
code and still abuses xattrs instead of a proper syscall interface.
That's far from being ready to merge.
