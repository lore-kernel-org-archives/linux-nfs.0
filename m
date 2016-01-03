Return-Path: <BATV+79bc6ce57c55c66c7247+4515+infradead.org+hch@bombadil.srs.infradead.org>
Date: Sun, 3 Jan 2016 04:04:06 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 06/10] lockd: Send the inode to nlmclnt_setlockargs()
Message-ID: <20160103120406.GF18066@infradead.org>
References: <cover.1451480826.git.bcodding@redhat.com>
 <fd78daf54bba981f5e1db1e59ee49e6bb04d8654.1451480826.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <fd78daf54bba981f5e1db1e59ee49e6bb04d8654.1451480826.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

I'd use 'pass' instead of 'send' in the patch description, but otherwise
this looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>
