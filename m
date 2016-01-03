Return-Path: <BATV+79bc6ce57c55c66c7247+4515+infradead.org+hch@bombadil.srs.infradead.org>
Date: Sun, 3 Jan 2016 04:05:52 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 08/10] locks: Set FL_CLOSE when removing flock locks
 on close()
Message-ID: <20160103120552.GH18066@infradead.org>
References: <cover.1451480826.git.bcodding@redhat.com>
 <2c9e21196b0949087c892ffffe49d26174a54fdd.1451480826.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2c9e21196b0949087c892ffffe49d26174a54fdd.1451480826.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 30, 2015 at 08:14:04AM -0500, Benjamin Coddington wrote:
> Use FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
> NFS will depend on this flag to properly defer an unlock until IO under the
> current lock has completed.

I wish we had a different of for relasing locks vs acquiring them,
but for now this looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>
