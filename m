Return-Path: <BATV+2df5c2bfb1a9c4489209+4715+infradead.org+hch@bombadil.srs.infradead.org>
Date: Thu, 21 Jul 2016 01:22:16 -0700
From: "hch@infradead.org" <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "hch@infradead.org" <hch@infradead.org>,
        List Linux <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Message-ID: <20160721082216.GA15247@infradead.org>
References: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
 <20160719035843.GA24437@infradead.org>
 <F879054A-2116-40D5-90C9-473E71977E8A@redhat.com>
 <C44AB0DD-8FA3-42F2-B7DE-C694559A68EF@primarydata.com>
 <AB904138-E761-4F8F-AF97-0E8A4E067DB1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AB904138-E761-4F8F-AF97-0E8A4E067DB1@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 20, 2016 at 11:03:06AM -0400, Benjamin Coddington wrote:
> > > This debug output is identical for every cycle of the loop. Have to
> > > stop for the
> > > day.. more tomorrow.
> > > 
> > > Ben
> > > 
> > 
> > Duh??? It???s this patch: pNFS: Fix post-layoutget error handling in
> > pnfs_update_layout()
> > We have to pass through fatal errors??? I???ll fix it.
> 
> That's indeed fixed it up, and generic/207 passes now.  Thanks!

So I spoke too soon in my last mail, generic/207 still fails for me
with Trond's linux-next tree, although much later in the test now.

Does it include the changes that are supposed to fix the issue?
