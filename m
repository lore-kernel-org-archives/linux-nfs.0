Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60365 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab3KBPHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 11:07:38 -0400
Date: Sat, 2 Nov 2013 08:07:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, Bruce Fields <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131102150738.GA21133@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131028214030.GO31322@fieldses.org>
 <526FAF30.3060502@netapp.com>
 <20131029130649.GA29606@fieldses.org>
 <20131102135409.GC18961@infradead.org>
 <20131102144431.GB26983@fieldses.org>
 <20131102145105.GA4450@infradead.org>
 <38D14516-BAA4-45BB-8054-ED05AEC22C8F@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38D14516-BAA4-45BB-8054-ED05AEC22C8F@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 02, 2013 at 03:02:29PM +0000, Myklebust, Trond wrote:
> COMMIT has always had a metadata part to it, though. It guarantees stability of the ctime/mime and change attributes in addition to the file size and data.
> 
> IOW: it really is more akin to fsync() than to fdatasync().

That's fine, but so far it wasn't used for any purely metadata
operation.  E.g. if we allow it for a preallocation we should also
allow it for updating the size put the current file size.

And diverting from the spec to your implementation: we'd need a lot more
generic infrastructure to deal with unstable random non-data operations.
