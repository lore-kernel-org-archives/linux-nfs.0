Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39069 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbcEIHC4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 03:02:56 -0400
Date: Mon, 9 May 2016 00:02:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Enke Chen <enkechen@cisco.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] VFS: pass the flag setting by fcntl() to vfs
Message-ID: <20160509070248.GA24065@infradead.org>
References: <ebf888a1-ee45-a79b-6f72-43a8744e0196@cisco.com>
 <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
 <20160508104038.GA13657@infradead.org>
 <c5368586-ba17-11ae-6d48-ee244bedf6f9@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <c5368586-ba17-11ae-6d48-ee244bedf6f9@cisco.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 08, 2016 at 05:50:32PM -0700, Enke Chen wrote:
> As explained in the email, currently the validation of the flags does reach
> the vfs, but the setting does not.

s/vfs/fs/, and yes, that's intentional.

> We have an application that uses the FUSE
> to implement a user-space socket, and the flags are needed.

And that's not a supported use case.
