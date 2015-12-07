Return-Path: <BATV+7d580da61648ed217d10+4488+infradead.org+hch@bombadil.srs.infradead.org>
Date: Mon, 7 Dec 2015 11:22:22 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 02/10] NFS: Move the flock open mode check into
 nfs_flock()
Message-ID: <20151207192222.GA7938@infradead.org>
References: <cover.1449503713.git.bcodding@redhat.com>
 <cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com>
 <20151207184036.GA28959@infradead.org>
 <alpine.OSX.2.19.9992.1512071359370.60717@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1512071359370.60717@planck.local>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2015 at 02:13:47PM -0500, Benjamin Coddington wrote:
> I can fixup the comment for clarity as I just moved this chunk over.
> 
> I'm not aware that flock() has ever had this check, but posix locks requires
> it.  My understanding is that since NFS may simulate flock() with posix
> locking, the check is necessary for NFS.

Ah, right.  Maybe that's what should be in the comment here..
