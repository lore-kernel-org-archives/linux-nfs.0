Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755539AbbLGTYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 14:24:42 -0500
Date: Mon, 7 Dec 2015 14:24:39 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 02/10] NFS: Move the flock open mode check into
 nfs_flock()
In-Reply-To: <20151207192222.GA7938@infradead.org>
Message-ID: <alpine.OSX.2.19.9992.1512071423180.60717@planck.local>
References: <cover.1449503713.git.bcodding@redhat.com> <cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com> <20151207184036.GA28959@infradead.org> <alpine.OSX.2.19.9992.1512071359370.60717@planck.local>
 <20151207192222.GA7938@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Dec 2015, Christoph Hellwig wrote:

> On Mon, Dec 07, 2015 at 02:13:47PM -0500, Benjamin Coddington wrote:
> > I can fixup the comment for clarity as I just moved this chunk over.
> >
> > I'm not aware that flock() has ever had this check, but posix locks requires
> > it.  My understanding is that since NFS may simulate flock() with posix
> > locking, the check is necessary for NFS.
>
> Ah, right.  Maybe that's what should be in the comment here..

Yes, good idea.  That's where someone is going to look when they investigate
why their application breaks on NFS.

Ben
