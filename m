Return-Path: <adobriyan@gmail.com>
Date: Mon, 18 Jul 2016 20:24:44 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH] nfs: don't create zero-length requests
Message-ID: <20160718172444.GA2779@p183.telecom.by>
References: <9a3042bc347cd708966dbba03b14302b4819c1d1.1468852483.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9a3042bc347cd708966dbba03b14302b4819c1d1.1468852483.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 18, 2016 at 10:41:57AM -0400, Benjamin Coddington wrote:
> NFS doesn't expect requests with wb_bytes set to zero and may make
> unexpected decisions about how to handle that request at the page IO layer.
> Skip request creation if we won't have any wb_bytes in the request.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
