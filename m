Return-Path: <BATV+79bc6ce57c55c66c7247+4515+infradead.org+hch@bombadil.srs.infradead.org>
Date: Sun, 3 Jan 2016 04:01:43 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 02/10] NFS: Move the flock open mode check into
 nfs_flock()
Message-ID: <20160103120143.GB18066@infradead.org>
References: <cover.1451480826.git.bcodding@redhat.com>
 <7c9912459f09f3393a768870ad4d5f21215549f9.1451480826.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7c9912459f09f3393a768870ad4d5f21215549f9.1451480826.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

Looks fine, althought the switch label indentation is a little
unfortunate.

Reviewed-by: Christoph Hellwig <hch@lst.de>
