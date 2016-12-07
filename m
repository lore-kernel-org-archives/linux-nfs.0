Return-Path: <BATV+f057edef27fde81efa4e+4854+infradead.org+hch@bombadil.srs.infradead.org>
Date: Wed, 7 Dec 2016 08:30:26 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Serialize nfs_readdir()
Message-ID: <20161207163026.GA9166@infradead.org>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
 <a87df5d5ada87834a1cb9f1ab12ed5113d80eda7.1481117708.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a87df5d5ada87834a1cb9f1ab12ed5113d80eda7.1481117708.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2016 at 08:37:02AM -0500, Benjamin Coddington wrote:
> Optimizations to NFS to choose between READDIR and READDIRPLUS don't expect
> concurrent users of nfs_readdir(), and can cause the pagecache to
> repeatedly be invalidated unnecessarily for this case.  Fix this by
> serializing nfs_readdir() on the directory's rwsem.

Just implement .iterate instead of .iterate_shared and you'll get the
serialization for free.  While doing that please add a comment on why
it's serialized.
