Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49307 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbcEHKlI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 06:41:08 -0400
Date: Sun, 8 May 2016 03:40:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Enke Chen <enkechen@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] VFS: pass the flag setting by fcntl() to vfs
Message-ID: <20160508104038.GA13657@infradead.org>
References: <ebf888a1-ee45-a79b-6f72-43a8744e0196@cisco.com>
 <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

File systems don't really have a business getting this call, and fuse
file systems even less so.
